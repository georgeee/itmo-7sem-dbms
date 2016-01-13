CREATE TABLE Student (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL,
  GroupId INT NOT NULL
);
CREATE TABLE Lecturer (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL
);
CREATE TABLE StudentGroup (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL UNIQUE
);
CREATE TABLE Course (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL
);
CREATE TABLE Teaching (
  StudentId INT NOT NULL,
  CourseId INT NOT NULL,
  LecturerId INT NOT NULL,
  PRIMARY KEY (StudentId, CourseId)
);
CREATE TABLE Mark (
  StudentId INT NOT NULL,
  CourseId INT NOT NULL,
  Mark DECIMAL (4, 2) NOT NULL,
  PRIMARY KEY (StudentId, CourseId)
);

ALTER TABLE Student ADD CONSTRAINT FK_Student_GroupId FOREIGN KEY (GroupId) REFERENCES StudentGroup (Id);
ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_LecturerId FOREIGN KEY (LecturerId) REFERENCES Lecturer (Id);
ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_StudentId FOREIGN KEY (StudentId) REFERENCES Student (Id) ON DELETE CASCADE;
ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_CourseId FOREIGN KEY (CourseId) REFERENCES Course (Id);
ALTER TABLE Mark ADD CONSTRAINT FK_Mark_CourseId FOREIGN KEY (CourseId) REFERENCES Course (Id);
ALTER TABLE Mark ADD CONSTRAINT FK_Mark_StudentId FOREIGN KEY (StudentId) REFERENCES Student (Id) ON DELETE CASCADE;
ALTER TABLE Mark ADD CONSTRAINT CH_Mark_Mark CHECK (Mark >= 0 AND Mark <= 100);


