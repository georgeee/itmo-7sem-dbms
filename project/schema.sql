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
  PieceId INT NOT NULL,
  Canceled BOOLEAN NOT NULL DEFAULT False
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

CREATE TYPE NotificationEntityType AS ENUM ('Event', 'Composer', 'Piece', 'Venue', 'Performer');
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
ALTER TABLE Event ADD CONSTRAINT FK_Event_PieceId FOREIGN KEY (PieceId) REFERENCES Piece (Id);
ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_EventId FOREIGN KEY (EventId) REFERENCES Event (Id);
ALTER TABLE EventPerformer ADD CONSTRAINT FK_EventPerformer_PerformerId FOREIGN KEY (PerformerId) REFERENCES Performer (Id);
ALTER TABLE Subscription ADD CONSTRAINT FK_Subscription_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
ALTER TABLE Notification ADD CONSTRAINT FK_Notification_UserId FOREIGN KEY (UserId) REFERENCES PortalUser (Id);
ALTER TABLE NotificationEntity ADD CONSTRAINT FK_NotificationEntity_NotificationId FOREIGN KEY (NotificationId) REFERENCES Notification (Id);

ALTER TABLE I18n ADD CONSTRAINT UN_I18n UNIQUE (EntityType, EntityId, Key, Lang);
ALTER TABLE Country ADD CONSTRAINT UN_Country_Code UNIQUE (Code);
ALTER TABLE PortalUser ADD CONSTRAINT UN_PortalUser_Login UNIQUE (Login);
ALTER TABLE EventPerformer ADD CONSTRAINT UN_EventPerformer_EventId_PerformerId UNIQUE (EventId, PerformerId);
ALTER TABLE NotificationEntity ADD CONSTRAINT UN_NotificationEntity UNIQUE (NotificationId, EntityType, EntityId);
ALTER TABLE Subscription ADD CONSTRAINT UN_Subscription UNIQUE (EntityType, EntityId, UserId);

CREATE INDEX Event_Time ON Event (Time);

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
        VALUES (currval(pg_get_serial_sequence('Notification','Id')), 'Event', $1);
    END LOOP;
    UPDATE Event SET Canceled = True WHERE Id = $1;
  END IF;
END;
$cancelEvent$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION event_insert_trigger() RETURNS trigger AS $event_insert_trigger$
DECLARE
  u INT;
  n INT;
BEGIN
  CREATE TEMPORARY VIEW Matched AS
  SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
    SELECT 'Composer'::NotificationEntityType as t, c.Id FROM Composer c JOIN Piece p ON c.Id = p.ComposerId AND p.Id = NEW.PieceId
    UNION
    SELECT 'Piece', NEW.PieceId
    UNION
    SELECT 'Venue', NEW.VenueId
  ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
  FOR u IN SELECT DISTINCT UserId FROM Matched
  LOOP
    INSERT INTO Notification (Type, UserId) VALUES ('NEW_EVENT', u);
    SELECT currval(pg_get_serial_sequence('Notification','Id')) INTO n;
    INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
      SELECT n, 'Event', NEW.EventId;
    INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
      SELECT n, EntityType, EntityId FROM Matched;
  END LOOP;
END;
$event_insert_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER event_insert_trigger AFTER INSERT ON Event
FOR EACH ROW EXECUTE PROCEDURE event_insert_trigger();

CREATE OR REPLACE FUNCTION event_performer_insert_trigger() RETURNS trigger AS $event_performer_insert_trigger$
DECLARE
  u INT;
  n INT;
BEGIN
  CREATE TEMPORARY VIEW Matched AS
  SELECT s.EntityType, s.EntityId, s.UserId FROM Subscription s JOIN (
    SELECT 'Performer'::NotificationEntityType as t, NEW.PerformerId as Id
  ) cp ON cp.t = s.EntityType AND s.EntityId = cp.id;
  FOR u IN SELECT DISTINCT UserId FROM Matched
  LOOP
    SELECT nn.Id FROM Notification nn INTO n
      JOIN NotificationType nt ON nt.NotificationId = nn.Id
        AND nn.Type = 'NEW_EVENT' AND nt.EntityType = 'Event' AND nt.EntityId = NEW.EventId
        AND nn.UserId = u;
    IF n IS NULL THEN
      INSERT INTO Notification (Type, UserId) VALUES ('NEW_EVENT', u);
      SELECT currval(pg_get_serial_sequence('Notification','Id')) INTO n;
      INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
        SELECT n, 'Event', NEW.EventId;
    END IF;
    INSERT INTO NotificationEntity (NotificationId, EntityType, EntityId)
      SELECT n, EntityType, EntityId FROM Matched;
  END LOOP;
END;
$event_performer_insert_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER event_performer_insert_trigger AFTER INSERT ON EventPerformer
FOR EACH ROW EXECUTE PROCEDURE event_performer_insert_trigger();
