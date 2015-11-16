INSERT INTO StudentGroup (Id, Letter, Number) VALUES (1, 'M', 3437), (2, 'M', 3338);
INSERT INTO Student (Id, Name, Birthday, Sex, GroupId)
VALUES (1, 'George Agapov', '1994-04-30', True, 1), (2, 'George Konoplich', '1993-11-18', True, 1),
       (3, 'Mikhail Ivanov', '1995-09-12', True, 2), (4, 'Alina Ruslanova', '1995-02-04', False, 2);
INSERT INTO Teacher (Id, Name, Degree) VALUES (1, 'George Korneev', 'PHD'), (2, 'Andrew Stankevich', 'PHD'), (3, 'Ivan Sorokin', 'MASTER');
INSERT INTO Subject (Id, Name, ExamRequired, TeacherId)
VALUES (1, 'Java: basic', True, 1), (2, 'Java: advanced', True, 1),
       (3, 'Translation methods', False, 2), (4, 'C++', False, 3), (5, 'Discrete math: semester 3', True, 2);

INSERT INTO GroupSubject (GroupId, SubjectId) VALUES (1, 1), (2, 1), (1, 4);

INSERT INTO Mark (StudentId, SubjectId, Value, Type)
VALUES -- Java : basic
       (1, 1, 50, 'HW'), (1, 1, 15, 'EXAM'), 
       (2, 1, 10, 'PRACTICE'), (2, 1, 20, 'CW'), (2, 1, 20, 'HW'), (2, 1, 19, 'EXAM'),
       (3, 1, 34, 'HW'),
       (4, 1, 24, 'CW'), (4, 1, 20, 'EXAM'),
       -- C++
       (1, 4, 20, 'HW'), (1, 4, 25, 'HW'), (1, 4, 45, 'HW'),
       (3, 4, 45, 'HW')
