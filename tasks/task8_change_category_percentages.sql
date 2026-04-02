-- Change Homework percentage from 20% to 25% in CS432
UPDATE GradeCategories
SET percentage = 25
WHERE course_id = 1 AND category_name = 'Homework';

-- Adjust another category to keep total 100% (e.g., reduce Tests to 45%)
UPDATE GradeCategories
SET percentage = 45
WHERE course_id = 1 AND category_name = 'Tests';