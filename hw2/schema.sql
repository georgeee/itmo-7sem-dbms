CREATE TABLE Student (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL,
  Birthday DATE NOT NULL,
  Sex BOOLEAN NOT NULL,
  GroupId INT NOT NULL
);
CREATE TYPE AcademicDegree AS ENUM ('BACHELOR', 'MASTER', 'SPECIALIST', 'PHD');
CREATE TABLE Teacher (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL,
  Degree AcademicDegree
);
CREATE TABLE StudentGroup (
  Id SERIAL NOT NULL PRIMARY KEY,
  Letter CHAR (1) NOT NULL,
  Number INT NOT NULL
);
CREATE TABLE Subject (
  Id SERIAL NOT NULL PRIMARY KEY,
  Name VARCHAR (50) NOT NULL,
  ExamRequired BOOLEAN NOT NULL,
  TeacherId INT NOT NULL
);
CREATE TABLE GroupSubject (
  GroupId INT NOT NULL,
  SubjectId INT NOT NULL
);
CREATE TYPE MarkType AS ENUM ('EXAM', 'LAB', 'PRACTICE', 'HW', 'CW');
CREATE TABLE Mark (
  StudentId INT NOT NULL,
  SubjectId INT NOT NULL,
  Value DECIMAL (4, 2) NOT NULL,
  Type MarkType
);

ALTER TABLE Student ADD CONSTRAINT FK_Student_GroupId FOREIGN KEY (GroupId) REFERENCES StudentGroup (Id);
ALTER TABLE Subject ADD CONSTRAINT FK_Subject_TeacherId FOREIGN KEY (TeacherId) REFERENCES Teacher (Id);
ALTER TABLE GroupSubject ADD CONSTRAINT FK_GroupSubject_GroupId FOREIGN KEY (GroupId) REFERENCES StudentGroup (Id);
ALTER TABLE GroupSubject ADD CONSTRAINT FK_GroupSubject_SubjectId FOREIGN KEY (SubjectId) REFERENCES Subject (Id);
ALTER TABLE Mark ADD CONSTRAINT FK_Mark_SubjectId FOREIGN KEY (SubjectId) REFERENCES Subject (Id);
ALTER TABLE Mark ADD CONSTRAINT FK_Mark_StudentId FOREIGN KEY (StudentId) REFERENCES Student (Id);
ALTER TABLE Mark ADD CONSTRAINT CH_Mark_Value CHECK (Value >= 0 AND Value <= 100);

-- Ограничение на величину суммарной оценки можно реализовать только на триггерах, не стал заморачиваться
-- Реализовать проверку на привязанность группы студента к предмету при добавлении оценки также представляется проблематичным


