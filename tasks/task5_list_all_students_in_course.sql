-- List all students in CS432 (course_id = 1)
SELECT s.student_id, s.first_name, s.last_name, s.email
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.course_id = 1;