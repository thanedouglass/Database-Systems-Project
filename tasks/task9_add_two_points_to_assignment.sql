-- Add 2 points to every student's score on 'HW1' (assignment_id = 1)
UPDATE Scores
SET points_earned = points_earned + 2
WHERE assignment_id = 1;