-- Schema (without constraints):

--
-- CREATE TABLE Student (
--   Id SERIAL NOT NULL PRIMARY KEY,
--   Name VARCHAR (50) NOT NULL,
--   GroupId INT NOT NULL
-- );
-- CREATE TABLE Lecturer (
--   Id SERIAL NOT NULL PRIMARY KEY,
--   Name VARCHAR (50) NOT NULL
-- );
-- CREATE TABLE StudentGroup (
--   Id SERIAL NOT NULL PRIMARY KEY,
--   Name VARCHAR (50) NOT NULL UNIQUE
-- );
-- CREATE TABLE Course (
--   Id SERIAL NOT NULL PRIMARY KEY,
--   Name VARCHAR (50) NOT NULL
-- );
-- CREATE TABLE Teaching (
--   GroupId INT NOT NULL,
--   CourseId INT NOT NULL,
--   LecturerId INT NOT NULL,
--   PRIMARY KEY (GroupId, CourseId)
-- );
-- CREATE TABLE Mark (
--   StudentId INT NOT NULL,
--   CourseId INT NOT NULL,
--   Mark DECIMAL (4, 2) NOT NULL,
--   PRIMARY KEY (StudentId, CourseId)
-- );


-- ----------------------------------------------
-- #1
-- Информацию о студентах с заданной оценкой по предмету «Базы данных».
-- ----------------------------------------------

-- Let DBMS course have id = 1, interesting mark = 67

SELECT s.* FROM Student s
INNER JOIN Teaching t ON t.GroupId = s.GroupId
INNER JOIN Mark m ON s.Id = m.StudentId AND t.CourseId = m.CourseId
WHERE m.CourseId = 1 AND m.Mark = 67
;

-- ----------------------------------------------
-- #2a
-- Информацию о студентах не имеющих оценки по предмету «Базы данных»:
--    (1) среди всех студентов
-- ----------------------------------------------

SELECT s.* FROM Student s
LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = 1
WHERE m.Mark IS NULL
;

-- ----------------------------------------------
-- #2b
-- Информацию о студентах не имеющих оценки по предмету «Базы данных»:
--    (2) среди студентов, у которых есть этот предмет
-- ----------------------------------------------

SELECT s.* FROM Student s
INNER JOIN Teaching t ON t.GroupId = s.GroupId
LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = t.CourseId
WHERE m.Mark IS NULL AND t.CourseId = 1
;

-- ----------------------------------------------
-- #3
-- Информацию о студентах, имеющих хотя бы одну оценку у заданного лектора.
-- ----------------------------------------------

SELECT s.* FROM Student s
INNER JOIN Teaching t ON t.GroupId = s.GroupId
INNER JOIN Mark m ON s.Id = m.StudentId AND t.CourseId = m.CourseId
WHERE t.LecturerId = 1
GROUP BY s.id, t.LecturerId
;

-- ----------------------------------------------
-- #4
-- Идентификаторы студентов, не имеющих ни одной оценки у заданного лектора.
-- ----------------------------------------------

SELECT s.* FROM Student s
LEFT JOIN Teaching t ON t.GroupId = s.GroupId AND t.LecturerId = 1
LEFT JOIN Mark m ON s.Id = m.StudentId AND t.CourseId = m.CourseId
WHERE m.Mark IS NULL
;

-- ----------------------------------------------
-- #5a
-- Студентов, имеющих оценки по всем предметам заданного лектора.
-- (имеющие оценуи по всем предметам заданного лектора, которые они должны посещать)
-- ----------------------------------------------

SELECT s.* FROM Teaching t
INNER JOIN Student s ON s.GroupId = t.GroupId
LEFT JOIN Mark m ON m.CourseId = t.CourseId AND s.Id = m.StudentId
WHERE t.LecturerId = 1
GROUP BY s.Id
HAVING bool_and(m.Mark IS NOT NULL)
;

-- ----------------------------------------------
-- #5b
-- Студентов, имеющих оценки по всем предметам заданного лектора.
-- (имеющие оценки по всем предметам, которые читает заданный лектор)
-- ----------------------------------------------

SELECT s.* FROM Teaching t
CROSS JOIN Student s
LEFT JOIN Mark m ON m.CourseId = t.CourseId AND s.Id = m.StudentId 
WHERE t.LecturerId = 1
GROUP BY s.Id
HAVING bool_and(m.Mark IS NOT NULL)
;

-- ----------------------------------------------
-- #6
-- Для каждого студента имя и предметы, которые он должен посещать.
-- ----------------------------------------------

SELECT s.Id, s.Name, c.Id, c.Name FROM Student s
INNER JOIN Teaching t ON t.GroupId = s.GroupId
INNER JOIN Course c ON c.Id = t.CourseId
;

-- ----------------------------------------------
-- #7
-- По лектору всех студентов, у которых он хоть что-нибудь преподавал.
-- ----------------------------------------------

SELECT s.* FROM Teaching t
INNER JOIN Student s ON s.GroupId = t.GroupId
WHERE t.LecturerId = 1
;

-- ----------------------------------------------
-- #8
-- Пары студентов, такие, что все сданные первым студентом предметы сдал и второй студент.
-- ----------------------------------------------

SELECT s1.Id, s1.Name, s2.Id, s2.Name FROM Mark m1
INNER JOIN Student s1 ON s1.Id = m1.StudentId
INNER JOIN Student s2 ON s2.Id > m1.StudentId
LEFT JOIN Mark m2 ON m1.CourseId = m2.CourseId AND m2.StudentId = s2.Id
GROUP BY s1.Id, s2.Id
HAVING bool_and(m2.Mark IS NOT NULL)
;

-- ----------------------------------------------
-- #9
-- Такие группы и предметы, что все студенты группы сдали предмет.
-- ----------------------------------------------

SELECT g.Name, c.Id, c.Name FROM Teaching t
INNER JOIN StudentGroup g ON g.Id = t.GroupId
INNER JOIN Course c ON c.Id = t.CourseId
INNER JOIN Student s ON s.GroupId = g.Id
LEFT JOIN Mark m ON m.StudentId = s.Id AND m.CourseId = c.Id
GROUP BY g.Id, c.Id
HAVING bool_and(m.Mark IS NOT NULL)
;

-- ----------------------------------------------
-- #10a
-- Средний балл студента.
--   по идентификатору
-- (учитываются только предметы, по которым у студента есть оценка)
-- ----------------------------------------------

SELECT avg(m.Mark) FROM Mark m
WHERE m.StudentId = 1
;

-- ----------------------------------------------
-- #10b
-- Средний балл студента.
--   для каждого студента
-- (учитываются только предметы, по которым у студента есть оценка)
-- ----------------------------------------------

SELECT s.*, avg(m.Mark) FROM Mark m
JOIN Student s ON s.Id = m.StudentId
GROUP BY s.Id
;

-- ----------------------------------------------
-- #11
-- Средний балл средних баллов студентов каждой группы.
-- (учитываются только предметы, по которым у студента есть оценка)
-- ----------------------------------------------

SELECT g.*, avg(m.mark) FROM StudentGroup g
JOIN Student s ON s.GroupId = g.Id
JOIN (SELECT s.Id, avg(m.Mark) as mark FROM Mark m
        JOIN Student s ON s.Id = m.StudentId
        GROUP BY s.Id) m ON m.Id = s.Id
GROUP BY g.Id
;

-- ----------------------------------------------
-- #12
-- Для каждого студента число предметов, которые у него были,
--   число сданных предметов и число не сданных предметов.
-- ----------------------------------------------

SELECT s.*, t1.c as total, t2.c as closed, t1.c - t2.c as open FROM Student s
JOIN (SELECT count(*) as c, t.GroupId as gid FROM Teaching t GROUP BY t.GroupId) as t1 ON t1.gid = s.GroupId
JOIN (SELECT count(m.Mark) as c, s.Id as sid FROM Teaching t
        JOIN Student s ON t.GroupId = s.GroupId
        LEFT JOIN Mark m ON s.Id = m.StudentId AND m.CourseId = t.CourseId
        GROUP BY s.Id) as t2 ON t2.sid = s.Id
