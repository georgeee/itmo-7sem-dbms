CREATE TABLE Composer (
  Id SERIAL NOT NULL PRIMARY KEY,
  DateOfBirth DATE,
  DateOfDeath DATE
);

CREATE TYPE I18nEntity AS ENUM ('Composer', 'Piece', 'Venue', 'City', 'Performer', 'Event', 'EventPerformer', 'Country');
CREATE TYPE I18nKey AS ENUM ('Name', 'Address', 'Role');
CREATE TYPE I18nLang AS ENUM ('en', 'ru', 'ge');
CREATE TABLE I18n (
  EntityType I18nEntity NOT NULL,
  EntityId INT NOT NULL,
  Key I18nKey NOT NULL,
  Lang I18nLang NOT NULL,
  Value VARCHAR(1024) NOT NULL
);

CREATE TYPE PieceType AS ENUM ('Opera', 'Ballet', 'Symphony');
CREATE TABLE Piece (
  Id SERIAL NOT NULL PRIMARY KEY,
  Type PieceType,
  ComposerId INT NOT NULL,
  GeneralPieceId INT
);

CREATE TABLE Venue (
  Id SERIAL NOT NULL PRIMARY KEY,
  CityId INT NOT NULL
);

CREATE TABLE City (
  Id SERIAL NOT NULL PRIMARY KEY,
  CountryId INT NOT NULL
);

CREATE TABLE Country (
  Id SERIAL NOT NULL PRIMARY KEY,
  Code VARCHAR(3) NOT NULL
);

CREATE TABLE Performer (
  Id SERIAL NOT NULL PRIMARY KEY
);

CREATE TABLE Event (
  Id SERIAL NOT NULL PRIMARY KEY,
  Time TIMESTAMP WITH TIME ZONE,
  VenueId INT NOT NULL,
  Canceled BOOLEAN NOT NULL DEFAULT False
);

CREATE TABLE EventPiece (
  EventId INT NOT NULL,
  PieceId INT NOT NULL
);

CREATE TYPE EPInstrument AS ENUM ('Conductor', 'Piano', 'Flute', 'Violin', 'Cello', 'Voice');
CREATE TABLE EventPerformer (
  Id SERIAL NOT NULL PRIMARY KEY,
  EventId INT NOT NULL,
  PerformerId INT NOT NULL,
  Instrument EPInstrument
);

CREATE TABLE PortalUser (
  Id SERIAL NOT NULL PRIMARY KEY,
  Login VARCHAR(50) NOT NULL,
  Name VARCHAR(50)
);

CREATE TYPE NotificationType AS ENUM ('NEW_EVENT', 'CANCELED_EVENT');
CREATE TABLE Notification (
  Id SERIAL NOT NULL PRIMARY KEY,
  Type NotificationType NOT NULL,
  UserId INT NOT NULL,
  CreatedTime TIMESTAMP NOT NULL DEFAULT current_timestamp,
  Read BOOLEAN NOT NULL DEFAULT False
);

CREATE TYPE NotificationEntityType AS ENUM ('Event', 'Composer', 'Piece', 'Venue', 'Performer', 'City', 'Country');
CREATE TABLE NotificationEntity (
  NotificationId INT NOT NULL,
  EntityType NotificationEntityType NOT NULL,
  EntityId INT NOT NULL
);

CREATE TABLE Subscription (
  EntityType NotificationEntityType NOT NULL,
  EntityId INT NOT NULL,
  UserId INT NOT NULL
);

ALTER TABLE Piece ADD CONSTRAINT FK_Piece_ComposerId FOREIGN KEY (ComposerId) REFERENCES Composer (Id);
ALTER TABLE Piece ADD CONSTRAINT FK_Piece_GeneralPieceId FOREIGN KEY (GeneralPieceId) REFERENCES Piece (Id);
ALTER TABLE Venue ADD CONSTRAINT FK_Venue_CityId FOREIGN KEY (CityId) REFERENCES City (Id);
ALTER TABLE City ADD CONSTRAINT FK_City_CountryId FOREIGN KEY (CountryId) REFERENCES Country (Id);
ALTER TABLE Event ADD CONSTRAINT FK_Event_VenueId FOREIGN KEY (VenueId) REFERENCES Venue (Id);
ALTER TABLE EventPiece ADD CONSTRAINT FK_EventPiece_PieceId FOREIGN KEY (PieceId) REFERENCES Piece (Id);
ALTER TABLE EventPiece ADD CONSTRAINT FK_EventPiece_EventId FOREIGN KEY (EventId) REFERENCES Event (Id);
ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_EventId FOREIGN KEY (EventId) REFERENCES Event (Id);
ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_PerformerId FOREIGN KEY (PerformerId) REFERENCES Performer (Id);
ALTER TABLE Subscription ADD CONSTRAINT FK_Subscription_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
ALTER TABLE Notification ADD CONSTRAINT FK_Notification_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
ALTER TABLE NotificationEntity ADD CONSTRAINT FK_NotificationEntity_NotificationId FOREIGN KEY (NotificationId) REFERENCES Notification (Id);

ALTER TABLE I18n ADD CONSTRAINT UN_I18n UNIQUE (EntityType, EntityId, Key, Lang);
ALTER TABLE Country ADD CONSTRAINT UN_Country_Code UNIQUE (Code);
ALTER TABLE PortalUser ADD CONSTRAINT UN_PortalUser_Login UNIQUE (Login);
ALTER TABLE EventPerformer ADD CONSTRAINT UN_EventPerformer_EventId_PerformerId UNIQUE (EventId, PerformerId);
ALTER TABLE EventPiece ADD CONSTRAINT UN_EventPiece_EventId_PieceId UNIQUE (EventId, PieceId);
ALTER TABLE NotificationEntity ADD CONSTRAINT UN_NotificationEntity UNIQUE (NotificationId, EntityType, EntityId);
ALTER TABLE Subscription ADD CONSTRAINT UN_Subscription UNIQUE (EntityType, EntityId, UserId);

CREATE INDEX Ix_Event_Time ON Event (Time);
CREATE INDEX Ix_I18n_Lang ON I18n (Lang);

ALTER TABLE Composer ADD CONSTRAINT Composer_Dates CHECK (DateOfBirth < DateOfDeath);
ALTER TABLE I18n ADD CONSTRAINT I18n_Key_EntityType CHECK ((Key = 'Name' AND EntityType != 'EventPerformer') OR (Key = 'Address' AND EntityType = 'Venue') OR (Key = 'Role' AND EntityType = 'EventPerformer'));

CREATE OR REPLACE FUNCTION cancelEvent(int) RETURNS void AS $cancelEvent$
DECLARE
  u INT;
  _canceled BOOLEAN;
BEGIN
  SELECT Canceled FROM Event INTO _canceled WHERE Id = $1;
  IF _canceled THEN
    RAISE EXCEPTION 'already canceled';
  ELSE
    FOR u IN SELECT UserId FROM Subscription
             WHERE EntityType = 'Event' AND EntityId = $1
    LOOP
      INSERT INTO Notification (Type, UserId) VALUES ('CANCELED_EVENT', u);
      INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
        VALUES (currval(pg_get_serial_sequence('notification','id')), 'Event', $1);
    END LOOP;
    UPDATE Event SET Canceled = True WHERE Id = $1;
  END IF;
END;
$cancelEvent$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clear_matched() RETURNS void AS $clear_matched$
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS Matched (
    EntityType NotificationEntityType,
    EntityId INT NOT NULL,
    UserId INT NOT NULL
  ) ON COMMIT DROP;
  TRUNCATE Matched;
END;

$clear_matched$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION event_process_matched(int) RETURNS void AS $event_process_matched$
DECLARE
  u INT;
  n INT;
BEGIN
  FOR u IN SELECT DISTINCT UserId FROM Matched
  LOOP
    SELECT nn.Id FROM Notification nn INTO n
      JOIN NotificationEntity nt ON nt.NotificationId = nn.Id
        AND nn.Type = 'NEW_EVENT' AND nt.EntityType = 'Event' AND nt.EntityId = $1
        AND nn.UserId = u;
    IF n IS NULL THEN
      INSERT INTO Notification (Type, UserId) VALUES ('NEW_EVENT', u);
      SELECT currval(pg_get_serial_sequence('notification','id')) INTO n;
      INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
        SELECT n, 'Event', $1;
    END IF;
    INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
      SELECT n, EntityType, EntityId FROM Matched;
  END LOOP;
END;
$event_process_matched$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION event_insert_trigger() RETURNS trigger AS $event_insert_trigger$
DECLARE
  u INT;
  n INT;
BEGIN
  PERFORM clear_matched();
  INSERT INTO Matched (EntityType, EntityId, UserId)
  SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
    SELECT 'Venue'::NotificationEntityType as t, NEW.VenueId as Id
    UNION
    SELECT 'City'::NotificationEntityType as t, v.CityId as Id FROM Venue v WHERE v.Id = NEW.VenueId
    UNION
    SELECT 'Country'::NotificationEntityType as t, c.CountryId as Id
        FROM Venue v
        JOIN City c ON c.Id = v.CityId
        WHERE v.Id = NEW.VenueId
  ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
  PERFORM event_process_matched(NEW.Id);
  RETURN NEW;
END;
$event_insert_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER event_insert_trigger AFTER INSERT ON Event
FOR EACH ROW EXECUTE PROCEDURE event_insert_trigger();

CREATE OR REPLACE FUNCTION event_performer_insert_trigger() RETURNS trigger AS $event_performer_insert_trigger$
DECLARE
  u INT;
  n INT;
BEGIN
  PERFORM clear_matched();
  INSERT INTO Matched (EntityType, EntityId, UserId)
  SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
    SELECT 'Performer'::NotificationEntityType as t, NEW.PerformerId as Id
  ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
  PERFORM event_process_matched(NEW.EventId);
  RETURN NEW;
END;
$event_performer_insert_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER event_performer_insert_trigger AFTER INSERT ON EventPerformer
FOR EACH ROW EXECUTE PROCEDURE event_performer_insert_trigger();


CREATE OR REPLACE FUNCTION event_piece_insert_trigger() RETURNS trigger AS $event_piece_insert_trigger$
DECLARE
  u INT;
  n INT;
BEGIN
  PERFORM clear_matched();
  INSERT INTO Matched (EntityType, EntityId, UserId)
  SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
    SELECT 'Composer'::NotificationEntityType as t, c.Id FROM Composer c JOIN Piece p ON c.Id = p.ComposerId AND p.Id = NEW.PieceId
    UNION
    SELECT 'Piece', p.GeneralPieceId FROM Piece p WHERE p.Id = NEW.PieceId AND p.GeneralPieceId IS NOT NULL
    UNION
    SELECT 'Piece', NEW.PieceId
  ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
  PERFORM event_process_matched(NEW.EventId);
  RETURN NEW;
END;
$event_piece_insert_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER event_piece_insert_trigger AFTER INSERT ON EventPiece
FOR EACH ROW EXECUTE PROCEDURE event_piece_insert_trigger();

CREATE VIEW EventInfo AS
(
  SELECT e.*, l.Lang,
         iE.Value as EventName,
         iV.Value as VenueName,
         iVA.Value as VenueAddress,
         v.CityId,
         iCi.Value as CityName,
         ci.CountryId,
         iCu.Value as CountryName
  FROM Event e
  CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
  JOIN Venue v ON v.Id = e.VenueId
  JOIN City ci ON ci.Id = v.CityId
  JOIN Country cu ON cu.Id = ci.CountryId
  LEFT JOIN I18n iE ON iE.EntityType = 'Event' AND iE.EntityId = e.VenueId AND iE.Lang = l.Lang AND iE.Key = 'Name'
  LEFT JOIN I18n iV ON iV.EntityType = 'Venue' AND iV.EntityId = e.VenueId AND iV.Lang = l.Lang AND iV.Key = 'Name'
  LEFT JOIN I18n iVA ON iVA.EntityType = 'Venue' AND iVA.EntityId = e.VenueId AND iVA.Lang = l.Lang AND iVA.Key = 'Address'
  LEFT JOIN I18n iCi ON iCi.EntityType = 'City' AND iCi.EntityId = ci.Id AND iCi.Lang = l.Lang AND iCi.Key = 'Name'
  LEFT JOIN I18n iCu ON iCu.EntityType = 'Country' AND iCu.EntityId = ci.Id AND iCu.Lang = l.Lang AND iCu.Key = 'Name'
);
CREATE VIEW EventPieceInfo AS
(
  SELECT ep.*, l.Lang,
         iP.Value as PieceName,
         iC.Value as ComposerName,
         p.Type as PieceType,
         p.GeneralPieceId,
         pg.Type as GeneralPieceType,
         iG.Value as GeneralPieceName,
         co.DateOfBirth as composerDateOfBirth,
         co.DateOfDeath as composerDateOfDeath
  FROM EventPiece ep
  CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
  JOIN Piece p ON p.Id = ep.PieceId
  JOIN Composer co ON co.Id = p.ComposerId
  LEFT JOIN Piece pg ON pg.Id = p.GeneralPieceId
  LEFT JOIN I18n iP ON iP.EntityType = 'Piece' AND iP.EntityId = ep.PieceId AND iP.Lang = l.Lang AND iP.Key = 'Name'
  LEFT JOIN I18n iG ON iG.EntityType = 'Piece' AND iG.EntityId = p.GeneralPieceId AND iG.Lang = l.Lang AND iG.Key = 'Name'
  LEFT JOIN I18n iC ON iC.EntityType = 'Composer' AND iC.EntityId = p.ComposerId AND iC.Lang = l.Lang AND iC.Key = 'Name'
);
CREATE VIEW EventPerformerInfo AS
(
  SELECT ep.*, l.Lang,
         iP.Value as PerformerName,
         iR.Value as Role
  FROM EventPerformer ep
  CROSS JOIN (SELECT DISTINCT Lang FROM I18n) l
  LEFT JOIN I18n iP ON iP.EntityType = 'Performer' AND iP.EntityId = ep.PerformerId AND iP.Lang = l.Lang AND iP.Key = 'Name'
  LEFT JOIN I18n iR ON iR.EntityType = 'EventPerformer' AND iR.EntityId = ep.Id AND iR.Lang = l.Lang AND iR.Key = 'Role'
);
