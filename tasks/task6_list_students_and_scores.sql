-- For CS432 (course_id = 1)
SELECT s.student_id, s.first_name, s.last_name,
       a.assignment_name, sc.points_earned, a.max_points
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Scores sc ON s.student_id = sc.student_id
JOIN Assignments a ON sc.assignment_id = a.assignment_id
WHERE e.course_id = 1
ORDER BY s.student_id, a.assignment_id;