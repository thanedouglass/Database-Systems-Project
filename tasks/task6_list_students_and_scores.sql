-- For CS432 (course_id = 1)
SELECT s.student_id, s.first_name, s.last_name,
       a.assignment_name, sc.points_earned, a.max_points
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
CROSS JOIN Assignments a   -- or use a LEFT JOIN from a derived table of enrollments × assignments
LEFT JOIN Scores sc ON sc.student_id = s.student_id AND sc.assignment_id = a.assignment_id
WHERE e.course_id = 1 AND a.course_id = 1
ORDER BY s.student_id, a.assignment_id;
