--================================================
--
-- DBMS, HW7
-- Made by Agapov George, group M3437

-- ===============================================


-- Schema:
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

-- Test data:

INSERT INTO StudentGroup (Id, Name) VALUES (1, 'M3437'), (2, 'M3338'), (3, 'M3339'), (4, 'M3439');
INSERT INTO Student (Id, Name, GroupId)
VALUES (1, 'George Agapov', 1), (2, 'George Konoplich', 1),
       (3, 'Mikhail Ivanov', 2), (4, 'Alina Ruslanova', 2), (5, 'Rahat Nurmusalaev', 4), (6, 'Mikhail Suvorov', 3);
INSERT INTO Lecturer (Id, Name) VALUES (1, 'George Korneev'), (2, 'Andrew Stankevich'), (3, 'Ivan Sorokin'), (4, 'Anton Kovalev');
INSERT INTO Course (Id, Name) VALUES (1, 'Java: basic'), (2, 'Java: advanced'),
       (3, 'Translation methods'), (4, 'C++'), (5, 'Discrete math: semester 3');
INSERT INTO Teaching (StudentId, CourseId, LecturerId)
VALUES (1, 1, 1), (1, 4, 3), (2, 1, 1), (2, 4, 3), -- group #1
      (3, 1, 1), (3, 4, 2), (3, 2, 1), (4, 1, 1), (4, 4, 2), (4, 2, 1), -- group #2
      (6, 2, 1) -- group #3
      ;
INSERT INTO Mark (StudentId, CourseId, Mark) VALUES (1, 4, 90), (2, 4, 70), (3, 1, 85), (1, 1, 67), (4, 2, 76), (4, 1, 67), (2, 1, 78);




---------------------------------------
-- 1. Напишите запрос, удаляющий всех студентов, не имеющих долгов.
---------------------------------------

-- This relies on "ON DELETE CASCADE" constraint in Mark table
-- Could rewritten without such assumptions, but would require more than one request (plus possibly creation of temporary table)

DELETE FROM Student WHERE Id IN (
  SELECT s.Id FROM Student s
  LEFT JOIN Teaching t ON t.StudentId = s.Id
  LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = t.CourseId
  GROUP BY s.Id
  HAVING (MIN(m.mark) >= 60 AND bool_and(m.Mark IS NOT NULL))
         OR bool_and(t.CourseId IS NULL)
);

---------------------------------------
-- 2. Напишите запрос, удаляющий всех студентов, имеющих 3 и более долгов.
---------------------------------------

DELETE FROM Student WHERE Id IN (
  SELECT s.Id FROM Student s
  JOIN Teaching t ON t.StudentId = s.Id
  LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = t.CourseId
  GROUP BY s.Id
  HAVING NOT(MIN(m.mark) >= 60 AND bool_and(m.Mark IS NOT NULL))
         AND COUNT(*) >= 3
);

---------------------------------------
-- 3. Напишите запрос, удаляющий все группы, в которых нет студентов.
---------------------------------------

DELETE FROM StudentGroup WHERE Id NOT IN (
  SELECT GroupId FROM Student s
  GROUP BY GroupId
);

---------------------------------------
-- 4. Создайте view Losers в котором для каждого студента, имеющего долги указано их количество.
---------------------------------------

CREATE VIEW Losers AS
(
  SELECT s.Id AS Id, s.Name as Name, COUNT(*) as Count FROM Student s
  JOIN Teaching t ON t.StudentId = s.Id
  LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = t.CourseId
  GROUP BY s.Id
  HAVING NOT(MIN(m.mark) >= 60 AND bool_and(m.Mark IS NOT NULL))
);

---------------------------------------
-- 5. Создайте таблицу LoserT, в которой содержится та же информация, что во view Losers.
-- Эта таблица должна автоматически обновляться при изменении таблицы с баллами.
---------------------------------------

CREATE TABLE LoserT (
  Id INTEGER NOT NULL PRIMARY KEY,
  Count INTEGER NOT NULL
);

INSERT INTO LoserT
SELECT Id, Count FROM Losers;

CREATE OR REPLACE FUNCTION inc_losert_row(int, int) RETURNS void AS $inc_losert_row$
DECLARE
  count LoserT.count%TYPE;
BEGIN
  SELECT l.Count FROM LoserT l INTO count WHERE Id = $1;
  count := COALESCE(count, 0) + $2;
  DELETE FROM LoserT WHERE Id = $1;
  IF count > 0 THEN
    INSERT INTO LoserT (Id, Count) VALUES ($1, count);
  END IF;
END;
$inc_losert_row$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mark_update_trigger() RETURNS trigger AS $mark_update_trigger$
DECLARE
  studentId Student.Id%TYPE;
  oldMark Mark.Mark%TYPE;
  newMark Mark.Mark%TYPE;
BEGIN
  IF TG_OP = 'INSERT' THEN
    studentId := NEW.StudentId;
    newMark := NEW.Mark;
    oldMark := 0;
  ELSE
    IF TG_OP = 'DELETE' THEN
      newMark := 0;
    ELSE
      IF NEW.StudentId != OLD.StudentId OR NEW.CourseId != OLD.CourseId THEN
        RAISE EXCEPTION 'student_id or course_id should not change';
      END IF;
      newMark := NEW.Mark;
    END IF;
    oldMark := OLD.Mark;
    studentId := OLD.StudentId;
  END IF;
  IF (oldMark < 60) AND (newMark >= 60) THEN
    PERFORM inc_losert_row(studentId, -1);
  ELSIF (newMark < 60) AND (oldMark >= 60) THEN
    PERFORM inc_losert_row(studentId, 1);
  END IF;
  RETURN NEW;
END;
$mark_update_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER mark_update_trigger AFTER INSERT OR UPDATE OR DELETE ON Mark
FOR EACH ROW EXECUTE PROCEDURE mark_update_trigger();

-- Also to maintain consistency between LoserT and Loser we need to add trigger on Teaching

CREATE OR REPLACE FUNCTION teaching_update_trigger() RETURNS trigger AS $teaching_update_trigger$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM inc_losert_row(OLD.StudentId, -1);
  ELSIF TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION 'update of teaching is not allowed';
  ELSE
    PERFORM inc_losert_row(NEW.StudentId, 1);
  END IF;
  RETURN NEW;
END;
$teaching_update_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER teaching_update_trigger AFTER INSERT OR UPDATE OR DELETE ON Teaching
FOR EACH ROW EXECUTE PROCEDURE teaching_update_trigger();

---------------------------------------
-- 6. Отключите автоматическое обновление таблицы LoserT.
---------------------------------------

DROP TRIGGER mark_update_trigger ON Mark;
DROP TRIGGER teaching_update_trigger ON Teaching;

---------------------------------------
-- 7. Напишите запрос (один), которой обновляет таблицу LoserT, используя данные из таблицы NewPoints, в которой содержится информация о баллах, проставленных за последний день.
---------------------------------------

-- We assume that all of marks from NewPoints are completely new records to Mark table, i.e. made by INSERT (and not UPDATE)

CREATE TABLE NewPoints(
  StudentId INTEGER NOT NULL,
  Mark INTEGER NOT NULL
);

SELECT inc_losert_row(StudentId, -1) FROM NewPoints WHERE Mark >= 60;

---------------------------------------
-- 8. Добавьте проверку того, что все студенты одной группы изучают один и тот же набор курсов.
---------------------------------------

CREATE OR REPLACE FUNCTION teaching_consistency_trigger() RETURNS trigger AS $teaching_consistency_trigger$
DECLARE
  absent_student_count integer;
BEGIN
  -- Idea of query:
  -- 1. count number of courses, referred to a group (by any student) - innermost subquery
  -- 2. count number of courses per student, compare with number for group, filter only those students, for that values aren't equal
  -- 3. count number of students, selected in middle subquery
  SELECT COUNT(*) FROM (
    SELECT s2.Id FROM Teaching t2
    JOIN Student s2 ON s2.Id = t2.StudentId
    JOIN (
      SELECT g.Id, COUNT(DISTINCT t.CourseId) as cnt FROM StudentGroup g
      JOIN Student s ON s.GroupId = g.Id
      JOIN Teaching t ON t.StudentId = s.Id GROUP BY g.Id
    ) gc ON gc.Id = s2.GroupId
    GROUP BY s2.Id, gc.cnt
    HAVING Count(*) != gc.cnt
  ) r INTO absent_student_count;
  IF absent_student_count > 0 THEN
    RAISE EXCEPTION 'Inconsistency in Teahing table: some students belong to same group, but are listening different sets of courses';
  END IF;
  RETURN NEW;
END;
$teaching_consistency_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER teaching_consistency_trigger AFTER UPDATE OR INSERT OR DELETE ON Teaching
FOR EACH STATEMENT EXECUTE PROCEDURE teaching_consistency_trigger();
CREATE TRIGGER teaching_consistency_trigger AFTER UPDATE OR INSERT OR DELETE ON Student
FOR EACH STATEMENT EXECUTE PROCEDURE teaching_consistency_trigger();

---------------------------------------
-- 9. Создайте триггер, не позволяющий уменьшить баллы студента по предмету. При попытке такого изменения, баллы изменяться не должны.
---------------------------------------

CREATE OR REPLACE FUNCTION mark_not_lower_trigger() RETURNS trigger AS $mark_not_lower_trigger$
BEGIN
  IF OLD.Mark > NEW.Mark THEN
    RAISE EXCEPTION 'Not allowed to set lower mark: old=%, new=%', OLD.Mark, NEW.Mark;
  END IF;
  RETURN NEW;
END;
$mark_not_lower_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER mark_not_lower_trigger AFTER UPDATE ON Mark
FOR EACH ROW EXECUTE PROCEDURE mark_not_lower_trigger();
