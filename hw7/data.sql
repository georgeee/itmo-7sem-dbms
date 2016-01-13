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
