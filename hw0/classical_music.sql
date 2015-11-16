CREATE TABLE Composer (
  Id serial not null,
  Name varchar(100) not null,
  DateOfBirth date
);

CREATE TABLE MusicPiece (
  Id serial not null PRIMARY KEY,
  Name varchar(100) not null,
  GenreId integer not null,
  ComposerId integer not null
);

CREATE TABLE Genre (
  Id serial not null PRIMARY KEY,
  Name varchar(100) not null
);


ALTER TABLE Composer ADD CONSTRAINT Composer_Id PRIMARY KEY (Id);
ALTER TABLE MusicPiece ADD CONSTRAINT FK_MusicPiece_Composer FOREIGN KEY (ComposerId) REFERENCES Composer (Id);
ALTER TABLE MusicPiece ADD CONSTRAINT FK_MusicPiece_Genre FOREIGN KEY (GenreId) REFERENCES Genre (Id);
ALTER TABLE Genre ADD CONSTRAINT Genre_Name UNIQUE (Name);
ALTER TABLE Composer ADD CONSTRAINT Composer_Name UNIQUE (Name);
ALTER TABLE MusicPiece ADD CONSTRAINT MusicPiece_Name_ComposerId UNIQUE (ComposerId, Name);

INSERT INTO Composer (Id, Name, DateOfBirth) VALUES (1, 'Richard Wagner', '1813-05-22'), (2, 'Пётр Ильич Чайковский', NULL);
INSERT INTO Genre (Id, Name) VALUES (1, 'Symphony'), (2, 'Opera'), (3, 'Sonata'), (4, 'Suite'), (5, 'Ballet');
INSERT INTO MusicPiece (Name, GenreId, ComposerId) VALUES ('Siegfried', 2, 1), ('Symphony No. 6 "Pathetic"', 1, 2);
