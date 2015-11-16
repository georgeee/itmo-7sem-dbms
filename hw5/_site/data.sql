INSERT INTO StudentGroup (Id, Name) VALUES (1, 'M3437'), (2, 'M3338');
INSERT INTO Student (Id, Name, GroupId)
VALUES (1, 'George Agapov', 1), (2, 'George Konoplich', 1),
       (3, 'Mikhail Ivanov', 2), (4, 'Alina Ruslanova', 2);
INSERT INTO Lecturer (Id, Name) VALUES (1, 'George Korneev'), (2, 'Andrew Stankevich'), (3, 'Ivan Sorokin');
INSERT INTO Course (Id, Name) VALUES (1, 'Java: basic'), (2, 'Java: advanced'),
       (3, 'Translation methods'), (4, 'C++'), (5, 'Discrete math: semester 3');
INSERT INTO Teaching (GroupId, CourseId, LecturerId) VALUES (2, 1, 1), (1, 4, 3);
INSERT INTO Mark (StudentId, CourseId, Mark) VALUES (1, 4, 90), (2, 4, 70), (3, 1, 85), (4, 1, 67);
