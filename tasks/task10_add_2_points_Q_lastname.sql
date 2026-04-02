-- Add 2 points to all assignments of students with 'Q' in last name (Charlie Quinn)
UPDATE Scores
SET points_earned = points_earned + 2
WHERE student_id IN (
    SELECT student_id FROM Students WHERE last_name ILIKE '%Q%'
);