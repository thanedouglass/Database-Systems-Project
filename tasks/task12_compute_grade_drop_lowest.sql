-- Function to compute grade dropping the lowest score in a specific category
CREATE OR REPLACE FUNCTION compute_grade_drop_lowest(
    p_student_id INT,
    p_course_id INT,
    p_category_name VARCHAR
) RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_grade DECIMAL(5,2) := 0;
    category_record RECORD;
    assignment_count INT;
    category_contribution DECIMAL(5,2);
    ratios DECIMAL(5,2)[];
    ratio_sum DECIMAL(5,2);
    min_ratio DECIMAL(5,2);
    i INT;
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

        -- Get all ratios (points_earned/max_points) for this student & category
        SELECT ARRAY_AGG(sc.points_earned / a.max_points ORDER BY (sc.points_earned / a.max_points))
        INTO ratios
        FROM Scores sc
        JOIN Assignments a ON sc.assignment_id = a.assignment_id
        WHERE sc.student_id = p_student_id
          AND a.course_id = p_course_id
          AND a.category_id = category_record.category_id;

        -- If category is the one to drop lowest, remove smallest ratio
        IF category_record.category_name = p_category_name THEN
            IF array_length(ratios, 1) > 1 THEN
                -- Drop the first (smallest) element
                ratios := ratios[2:array_length(ratios, 1)];
                assignment_count := assignment_count - 1;
            ELSE
                -- If only one assignment, dropping lowest would leave none; keep it as is
                NULL;
            END IF;
        END IF;

        -- Sum the remaining ratios
        ratio_sum := 0;
        FOR i IN 1..array_length(ratios, 1) LOOP
            ratio_sum := ratio_sum + ratios[i];
        END LOOP;

        category_contribution := (ratio_sum / assignment_count) * category_record.percentage;
        total_grade := total_grade + category_contribution;
    END LOOP;

    RETURN ROUND(total_grade, 2);
END;
$$ LANGUAGE plpgsql;

-- Example: Compute grade for Alice (1) in CS432 (1) dropping lowest Homework score
SELECT compute_grade_drop_lowest(1, 1, 'Homework') AS alice_grade_drop_lowest_hw;