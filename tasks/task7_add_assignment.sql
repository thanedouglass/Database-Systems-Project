-- Add a new homework assignment 'HW3' to CS432
INSERT INTO Assignments (course_id, category_id, assignment_name, max_points)
VALUES (1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Homework'), 'HW3', 100);