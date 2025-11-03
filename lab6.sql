--1.1
CREATE TABLE employees(
    emp_id int primary key,
    emp_name VARCHAR (50),
    dept_id int,
    salary DECIMAL(10,2)
) ;
CREATE TABLE departments(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE projects
(
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id      INT,
    budget       DECIMAL(10, 2)
);
--1.2
INSERT INTO departments(dept_id,dept_name,location) VALUES
(101,'IT','Building A'),
(102,'HR','Building B'),
(103,'Finance','Building C'),
(104,'Marketing','Building D');

INSERT INTO employees(emp_id,emp_name,dept_id,salary) VALUES
(1,'John Smith',101,50000),
(2,'Jane Doe',102,60000),
(3,'Mike Johnson',101,55000),
(4,'Sarah Williams',103,65000),
(5,'Tom Brown',NULL,450000  );
INSERT INTO projects(project_id, project_name, dept_id, budget) VALUES
(1,'Website Redesign',101,100000),
(2,'Employee Training',102,50000),
(3,'Budget Analysis',103,75000),
(4,'Cloud Migration',101,150000),
(5,'AI Research',NULL,200000);
--2.1
SELECT e.emp_name , d.dept_name
FROM employees e CROSS JOIN departments d;
--4*5 = 20

--2.2
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

--2.3
SELECT e.*  , p.*
FROM employees e  CROSS JOIN projects p;

--3.1
SELECT e.emp_name , d.dept_name , d.location
FROM employees e INNER JOIN departments d on e.dept_id = d.dept_id;
--4 rows, Tom Brown doesnt have id
--3.2
SELECT emp_name,dept_name,location
FROM employees
INNER JOIN departments USING(dept_id);
--The USING clause automatically merges the join column (dept_id) into a single column in the output, whereas the ON version displays both employees.dept_id and departments.dept_id separately.
--3.3
SELECT emp_name, dept_name , location
FROM employees
NATURAL INNER JOIN departments;
--3.4
SELECT e.emp_name, d.dept_name , p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;

--4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
                                dept_dept, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;
--his value id NULL
--4.2
SELECT emp_name, dept_id, dept_name
FROM employees
         LEFT JOIN departments USING (dept_id);
--4.3
SELECT e.emp_name, e.dept_id
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
--Tom Browm
--4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
--5.1
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;
--5.2
SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON e.dept_id = d.dept_id;
--5.3
SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL

--6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;
--marketing and tom browm

--6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;
--6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without
employees'
        WHEN d.dept_id IS NULL THEN 'Employee without
department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
--7.1
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND
                                    d.location = 'Building A';
--7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--7.3
--No difference.
--For INNER JOIN, filtering in the ON clause or the WHERE clause produces the same result,
--because INNER JOIN only keeps matching rows, so both filters apply after the join condition.

--8.1
SELECT
 d.dept_name,
 e.emp_name,
 e.salary,
 p.project_name,
 p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;
--8.2
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;

--8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


-- 1. Difference between INNER JOIN and LEFT JOIN:
-- INNER JOIN returns only the rows that have matching values in both tables.
-- LEFT JOIN returns all rows from the left table, and matching rows from the right table (NULL if no match).

-- 2. When to use CROSS JOIN:
-- Use CROSS JOIN when you need all possible combinations of rows between two tables.
-- Example: creating a schedule (every employee paired with every project).

-- 3. Why ON vs WHERE matters for outer joins but not for inner joins:
-- In INNER JOIN, both ON and WHERE filters act the same way.
-- In OUTER JOIN, ON filters before adding NULL rows, while WHERE filters after.
-- Therefore, placing a condition in WHERE may exclude NULL results that would otherwise appear.

-- 4. Result of SELECT COUNT(*) FROM table1 CROSS JOIN table2 (5 rows × 10 rows):
-- 5 * 10 = 50 rows.

-- 5. How NATURAL JOIN determines which columns to join on:
-- NATURAL JOIN automatically joins tables on all columns with the same names in both tables.

-- 6. Risks of using NATURAL JOIN:
-- It may join on unintended columns if new columns with the same name are added later.
-- This can lead to incorrect results and hard-to-debug errors.

-- 7. Convert this LEFT JOIN to a RIGHT JOIN:
-- Original: SELECT * FROM A LEFT JOIN B ON A.id = B.id;
-- Converted: SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

-- 8. When to use FULL OUTER JOIN:
-- Use FULL OUTER JOIN when you need to include all rows from both tables,
-- showing matches where they exist and NULLs where they don’t (e.g. to find unmatched records on either side).
