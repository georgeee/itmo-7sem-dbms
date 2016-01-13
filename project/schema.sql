CREATE TABLE Composer (
  Id SERIAL NOT NULL PRIMARY KEY,
  DateOfBirth DATE,
  DateOfDeath DATE
);

CREATE TYPE I18nEntity AS ENUM ('Composer', 'Piece', 'Venue', 'City', 'Performer', 'Event', 'EventPerformer');
CREATE TYPE I18nKey AS ENUM ('Name', 'Address', 'Role');
CREATE TYPE I18nLang AS ENUM ('en', 'ru', 'ge');
CREATE TABLE I18n (
  EntityType I18nEntity NOT NULL,
  EntityId INT NOT NULL,
  Key I18nKey NOT NULL,
  Lang I18nLang NOT NULL
);

CREATE TYPE PieceType AS ENUM ('Opera', 'Ballet', 'Symphony');
CREATE TABLE Piece (
  Id SERIAL NOT NULL PRIMARY KEY,
  Type PieceType,
  ComposerId INT NOT NULL,
  GeneralPieceId INT NOT NULL
);

CREATE TABLE Venue (
  Id SERIAL NOT NULL PRIMARY KEY,
  CityId INT NOT NULL
);

CREATE TABLE City (
  Id SERIAL NOT NULL PRIMARY KEY,
  CountryId INT NOT NULL,
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
  StartTime TIMESTAMP WITH TIME ZONE,
  EndTime TIMESTAMP WITH TIME ZONE,
  VenueId INT NOT NULL,
  PieceId INT NOT NULL,
  Canceled BOOLEAN NOT NULL
);

CREATE TYPE EPInstrument AS ENUM ('Conductor', 'Piano', 'Flute', 'Violin', 'Cello');
CREATE TABLE EventPerformer (
  EventId INT NOT NULL,
  PerformerId INT NOT NULL,
  Instrument EPInstrument
);

CREATE TABLE User (
  Id SERIAL NOT NULL PRIMARY KEY,
  Login VARCHAR(50) NOT NULL,
  Name VARCHAR(50)
);

CREATE TYPE NotificationType AS ENUM ('NEW_EVENT', 'CANCELED_EVENT');
CREATE TABLE Notification (
  Id SERIAL NOT NULL PRIMARY KEY,
  Type NotificationType NOT NULL,
  UserId INT NOT NULL,
  CreatedTime TIMESTAMP NOT NULL,
  Read BOOLEAN NOT NULL
);

CREATE TYPE NotificationEntityType AS ENUM ('Event', 'Composer', 'Piece', 'Venue', 'Performer');
CREATE TABLE NotificationEntity (
  NotificationId INT NOT NULL,
  EntityType NotificationEntityType NOT NULL,
  EntityId INT NOT NULL
);
