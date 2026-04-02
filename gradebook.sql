-- gradebook.sql
-- Full implementation of Grade Book Database

-- Cleanup (optional, for re-runs)
DROP FUNCTION IF EXISTS compute_grade_drop_lowest(INT, INT, VARCHAR);
DROP FUNCTION IF EXISTS compute_grade(INT, INT);
DROP TRIGGER IF EXISTS check_category_sum_trigger ON GradeCategories;
DROP FUNCTION IF EXISTS check_category_sum();
DROP TABLE IF EXISTS Scores CASCADE;
DROP TABLE IF EXISTS Assignments CASCADE;
DROP TABLE IF EXISTS GradeCategories CASCADE;
DROP TABLE IF EXISTS Enrollments CASCADE;
DROP TABLE IF EXISTS Students CASCADE;
DROP TABLE IF EXISTS Courses CASCADE;

-- Table creation (as above)
-- ... (copy all CREATE TABLE statements from Section 2)
-- ... (copy INSERT statements)
-- ... (copy function definitions from Sections 11 & 12)

-- Example calls for tasks 4–12
-- (Include the SELECT statements as shown)