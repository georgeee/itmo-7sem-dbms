-- Оценки всех, сдавших экзамен по какому-л. предмету
SELECT st.name, su.name, SUM(m.Value) as sum
FROM Subject su
JOIN GroupSubject gs ON gs.SubjectId = su.Id
JOIN StudentGroup g ON g.Id = gs.GroupId
JOIN Student st ON st.GroupId = g.Id
LEFT JOIN Mark m ON m.SubjectId = su.Id AND m.StudentId = st.Id
GROUP BY st.id, su.id
HAVING ((SUM(m.Value) IS NOT NULL) AND SUM(m.Value) >= 60) AND (NOT su.examRequired OR BOOL_OR(m.Type = 'EXAM'));

-- Оценки всех, не сдавших экзамен по какому-л. предмету
SELECT st.name, su.name, SUM(m.Value) as sum
FROM Subject su
JOIN GroupSubject gs ON gs.SubjectId = su.Id
JOIN StudentGroup g ON g.Id = gs.GroupId
JOIN Student st ON st.GroupId = g.Id
LEFT JOIN Mark m ON m.SubjectId = su.Id AND m.StudentId = st.Id
GROUP BY st.id, su.id
HAVING ((SUM(m.Value) IS NULL) OR SUM(m.Value) < 60) OR (su.examRequired AND NOT BOOL_OR(m.Type = 'EXAM'));

-- Все предметы преподавателя Andrew Stankevich
SELECT su.name as subjectName, t.name as teacherName FROM Subject su
JOIN Teacher t ON t.Id = su.TeacherId
WHERE t.Id = 2;

-- Все девочки университета
SELECT st.name, CONCAT(g.Letter, g.Number) as groupName
FROM Student st
JOIN StudentGroup g ON g.Id = st.GroupId
WHERE st.sex = False;

-- Все студенты, слушающие курсы преподавателя Ivan Sorokin
SELECT st.name, su.name FROM Subject su
JOIN GroupSubject gs ON gs.SubjectId = su.Id
JOIN StudentGroup g ON g.Id = gs.GroupId
JOIN Student st ON st.GroupId = g.Id
WHERE su.TeacherId = 3;
