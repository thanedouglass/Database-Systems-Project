-- Create database (adjust for your DBMS, e.g., PostgreSQL)
-- CREATE DATABASE gradebook;
-- \c gradebook;

-- Table: Courses
CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    department VARCHAR(10) NOT NULL,
    course_number VARCHAR(10) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    semester VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    UNIQUE(department, course_number, semester, year)
);

-- Table: Students
CREATE TABLE Students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Table: Enrollments
CREATE TABLE Enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES Students(student_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    UNIQUE(student_id, course_id)
);

-- Table: GradeCategories (weights for each course)
CREATE TABLE GradeCategories (
    category_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    category_name VARCHAR(50) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL CHECK (percentage >= 0),
    UNIQUE(course_id, category_name)
);

-- Table: Assignments
CREATE TABLE Assignments (
    assignment_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES GradeCategories(category_id) ON DELETE CASCADE,
    assignment_name VARCHAR(100) NOT NULL,
    max_points DECIMAL(5,2) NOT NULL DEFAULT 100 CHECK (max_points > 0),
    UNIQUE(course_id, assignment_name)
);

-- Table: Scores
CREATE TABLE Scores (
    score_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES Students(student_id) ON DELETE CASCADE,
    assignment_id INT NOT NULL REFERENCES Assignments(assignment_id) ON DELETE CASCADE,
    points_earned DECIMAL(5,2) NOT NULL CHECK (points_earned >= 0),
    UNIQUE(student_id, assignment_id)
);

-- Trigger to ensure total percentages per course = 100
CREATE OR REPLACE FUNCTION check_category_sum()
RETURNS TRIGGER AS $$
DECLARE
    total DECIMAL(5,2);
BEGIN
    SELECT SUM(percentage) INTO total
    FROM GradeCategories
    WHERE course_id = NEW.course_id;
    IF total > 100 OR (TG_OP = 'UPDATE' AND total + (NEW.percentage - OLD.percentage) != 100) THEN
        RAISE EXCEPTION 'Total percentages for course % must equal 100 (currently %)', NEW.course_id, total;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_category_sum_trigger
AFTER INSERT OR UPDATE ON GradeCategories
FOR EACH ROW EXECUTE FUNCTION check_category_sum();

-- Insert sample data
INSERT INTO Courses (department, course_number, course_name, semester, year) VALUES
('CS', '432', 'Database Systems', 'Spring', 2026),
('MATH', '201', 'Calculus I', 'Fall', 2025);

INSERT INTO Students (first_name, last_name, email) VALUES
('Alice', 'Smith', 'alice@univ.edu'),
('Bob', 'Jones', 'bob@univ.edu'),
('Charlie', 'Quinn', 'charlie.q@univ.edu'),   -- last name contains 'Q'
('Diana', 'Prince', 'diana@univ.edu');

INSERT INTO Enrollments (student_id, course_id) VALUES
(1,1), (2,1), (3,1), (4,1),   -- all in CS432
(1,2), (3,2);                  -- some in MATH201

-- Categories for CS432
INSERT INTO GradeCategories (course_id, category_name, percentage) VALUES
(1, 'Participation', 10),
(1, 'Homework', 20),
(1, 'Tests', 50),
(1, 'Projects', 20);

-- Categories for MATH201
INSERT INTO GradeCategories (course_id, category_name, percentage) VALUES
(2, 'Homework', 30),
(2, 'Exams', 70);

-- Assignments for CS432
INSERT INTO Assignments (course_id, category_id, assignment_name, max_points) VALUES
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Homework'), 'HW1', 100),
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Homework'), 'HW2', 100),
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Tests'), 'Midterm', 100),
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Tests'), 'Final', 100),
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Projects'), 'Project1', 100),
(1, (SELECT category_id FROM GradeCategories WHERE course_id=1 AND category_name='Participation'), 'Participation', 100);

-- Assignments for MATH201
INSERT INTO Assignments (course_id, category_id, assignment_name, max_points) VALUES
(2, (SELECT category_id FROM GradeCategories WHERE course_id=2 AND category_name='Homework'), 'HW1', 50),
(2, (SELECT category_id FROM GradeCategories WHERE course_id=2 AND category_name='Exams'), 'Midterm', 100);

-- Scores for CS432
INSERT INTO Scores (student_id, assignment_id, points_earned) VALUES
(1,1,85), (1,2,90), (1,3,78), (1,4,88), (1,5,92), (1,6,100),
(2,1,70), (2,2,75), (2,3,65), (2,4,70), (2,5,80), (2,6,90),
(3,1,95), (3,2,88), (3,3,92), (3,4,85), (3,5,96), (3,6,100),
(4,1,60), (4,2,65), (4,3,55), (4,4,60), (4,5,70), (4,6,80);

-- Scores for MATH201
INSERT INTO Scores (student_id, assignment_id, points_earned) VALUES
(1,7,45), (1,8,88),
(3,7,48), (3,8,92);