-- Function to compute overall percentage grade for a student in a course
CREATE OR REPLACE FUNCTION compute_grade(p_student_id INT, p_course_id INT)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_grade DECIMAL(5,2) := 0;
    category_record RECORD;
    assignment_count INT;
    category_contribution DECIMAL(5,2);
    student_scores RECORD;
    ratio_sum DECIMAL(5,2);
BEGIN
    FOR category_record IN
        SELECT gc.category_id, gc.percentage, gc.category_name
        FROM GradeCategories gc
        WHERE gc.course_id = p_course_id
    LOOP
        -- Count assignments in this category
        SELECT COUNT(*) INTO assignment_count
        FROM Assignments a
        WHERE a.course_id = p_course_id AND a.category_id = category_record.category_id;

        IF assignment_count = 0 THEN
            CONTINUE;
        END IF;

        -- Sum of (points_earned / max_points) for this student in this category
        SELECT COALESCE(SUM(sc.points_earned / a.max_points), 0) INTO ratio_sum
        FROM Scores sc
        JOIN Assignments a ON sc.assignment_id = a.assignment_id
        WHERE sc.student_id = p_student_id
          AND a.course_id = p_course_id
          AND a.category_id = category_record.category_id;

        -- Contribution = (average ratio) * category percentage
        category_contribution := (ratio_sum / assignment_count) * category_record.percentage;
        total_grade := total_grade + category_contribution;
    END LOOP;

    RETURN ROUND(total_grade, 2);
END;
$$ LANGUAGE plpgsql;

-- Example: Compute grade for Alice (student_id=1) in CS432 (course_id=1)
SELECT compute_grade(1, 1) AS alice_grade_cs432;