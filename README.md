# Grade Book Database

## Project Overview
This project implements a grade book database for a professor to track student grades across multiple courses. It supports dynamic assignment categories, percentage-based grading, score tracking, and advanced queries including dropping the lowest score in a category.

## ER Diagram
![ER Diagram](./ER_Diagram.png)

The diagram shows the relationships between `Courses`, `Students`, `Enrollments`, `GradeCategories`, `Assignments`, and `Scores`. Primary keys are underlined, foreign keys are explicitly marked.

## Prerequisites
- PostgreSQL 12 or higher (includes PL/pgSQL support)
- `psql` command-line client
- (Optional) A database GUI like pgAdmin

## Setup Instructions

### 1. Clone or download the repository
Ensure the following files are present:
- `gradebook.sql` – Main database script
- `ER_Diagram.png` – Entity‑relationship diagram
- `README.md` – This file

### 2. Create a database
Open a terminal and run:
```bash
createdb gradebook
```

### 3. Execute the schema and data script
```bash
psql -d gradebook -f gradebook.sql
```

The script will:
- Drop any existing objects (for clean re‑runs)
- Create all tables with constraints and triggers
- Insert sample courses, students, enrollments, categories, assignments, and scores
- Define two functions: `compute_grade()` and `compute_grade_drop_lowest()`
- Display example queries for tasks 4‑12 (commented out by default)

### 4. Verify the installation
```bash
psql -d gradebook -c "\dt"
```

## How to Run Each Task
All task queries are included inside `gradebook.sql` (commented). Below are the essential commands.

| Task | Description | Command |
|------|-------------|---------|
| 4 | Avg/high/low of an assignment | `SELECT AVG(points_earned), MAX(points_earned), MIN(points_earned) FROM Scores WHERE assignment_id = 1;` |
| 5 | List students in a course | `SELECT s.* FROM Students s JOIN Enrollments e ON s.student_id = e.student_id WHERE e.course_id = 1;` |
| 6 | Students + all scores in a course | `SELECT s.first_name, s.last_name, a.assignment_name, sc.points_earned FROM Students s JOIN Enrollments e ... JOIN Scores sc ... JOIN Assignments a ... WHERE e.course_id = 1;` |
| 7 | Add an assignment | `INSERT INTO Assignments (course_id, category_id, assignment_name, max_points) VALUES (1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Homework'), 'HW3', 100);` |
| 8 | Change category percentages | `UPDATE GradeCategories SET percentage = 25 WHERE course_id = 1 AND category_name = 'Homework';` (also adjust another category to keep sum 100) |
| 9 | Add 2 points to all on an assignment | `UPDATE Scores SET points_earned = points_earned + 2 WHERE assignment_id = 1;` |
| 10 | Add 2 points to students with 'Q' in last name | `UPDATE Scores SET points_earned = points_earned + 2 WHERE student_id IN (SELECT student_id FROM Students WHERE last_name ILIKE '%Q%');` |
| 11 | Compute a student's grade | `SELECT compute_grade(1, 1);` (student 1 in course 1) |
| 12 | Compute grade dropping lowest score in a category | `SELECT compute_grade_drop_lowest(1, 1, 'Homework');` |

## Compilation & Execution Notes
- This is a SQL/PL/pgSQL project, so no separate "compilation" is required. The `psql -f` command executes the script directly.
- Functions are stored in the database and can be called repeatedly.
- The trigger on `GradeCategories` automatically enforces that category percentages sum to 100% per course.

## Test Cases & Expected Results
The sample data included in `gradebook.sql` produces the following outputs for the core tasks:

| Task | Query / Function Call | Expected Result |
|------|----------------------|-----------------|
| 4 | Average of HW1 (assignment_id=1) | 77.50 |
| 4 | Highest of HW1 | 95 |
| 4 | Lowest of HW1 | 60 |
| 5 | Number of students in CS432 (course_id=1) | 4 (Alice, Bob, Charlie, Diana) |
| 6 | Rows returned for CS432 | 24 rows (4 students × 6 assignments) |
| 7 | After insert, check `SELECT * FROM Assignments WHERE assignment_name='HW3'` | 1 row |
| 8 | After update, `SELECT * FROM GradeCategories WHERE course_id=1` | Participation 10%, Homework 25%, Tests 45%, Projects 20% |
| 9 | After update, HW1 scores increased by 2 | Alice: 87, Bob: 72, Charlie: 97, Diana: 62 |
| 10 | After update, Charlie's scores increase by 2 on all assignments | Charlie's scores all +2 |
| 11 | `compute_grade(1,1)` for Alice in CS432 | ~85.42 |
| 12 | `compute_grade_drop_lowest(1,1,'Homework')` for Alice | ~87.15 (higher than without drop) |

## Additional Notes
- The "lowest score dropped" function only drops one lowest score per student per specified category. It handles categories with one assignment gracefully (does not drop it).
- All foreign keys are defined with `ON DELETE CASCADE` where appropriate to maintain referential integrity.
- The schema uses `SERIAL` auto‑incrementing primary keys for simplicity.
