-- For assignment named 'HW1' in CS432
WITH target_assignment AS (
    SELECT assignment_id FROM Assignments
    WHERE assignment_name = 'HW1' AND course_id = 1
)
SELECT
    AVG(points_earned) AS avg_score,
    MAX(points_earned) AS highest_score,
    MIN(points_earned) AS lowest_score
FROM Scores
WHERE assignment_id = (SELECT assignment_id FROM target_assignment);