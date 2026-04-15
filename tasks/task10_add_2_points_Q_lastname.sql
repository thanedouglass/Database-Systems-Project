-- Add 2 points to all assignments of students with 'Q' in last name (Charlie Quinn)
UPDATE Scores
SET points_earned = points_earned + 2
WHERE assignment_id = 1   -- specify which assignment (e.g., HW1)
  AND student_id IN (SELECT student_id FROM Students WHERE last_name ILIKE '%Q%');
