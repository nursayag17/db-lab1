
--part a
CREATE DATABASE advanced_lab;

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(50) NOT NULL ,
    last_name VARCHAR(50) NOT NULL ,
    department VARCHAR(50) NOT NULL ,
    salary INT,
    hire_date DATE,
    status VARCHAR(50) default   'Active'
)
CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY ,
    dept_name VARCHAR(50) NOT NULL ,
    budget INT,
    manager_id INT
)
CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY ,
    project_name VARCHAR(50) NOT NULL ,
    dept_id INT ,
    start_date DATE,
    end_date DATE,
    budget INT
)
--for tasks
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 120000, 1),
    ('HR', 60000, 2),
    ('Sales', 90000, 3),
    ('Finance', 150000, 4);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
-- старый сотрудник с высокой зарплатой (под задачу 8 -> станет Senior)
('Old', 'Boss', 'IT', 90000, '2015-05-10', 'Active'),

-- средняя зарплата (под задачу 9 -> попадёт в Senior department)
('Middle', 'Guy', 'HR', 70000, '2021-03-15', 'Active'),

-- низкая зарплата (под задачу 9 -> станет Junior)
('Low', 'Worker', 'Sales', 35000, '2022-11-20', 'Active'),

-- для задачи 12 (Sales + Promoted)
('Bek', 'Almas', 'Sales', 40000, '2023-02-10', 'Active'),

-- уволенный сотрудник (под задачу 13)
('Term', 'Inated', 'HR', 50000, '2020-05-05', 'Terminated'),

-- сотрудник с NULL salary и NULL department (под Part E)
('Nuller', 'Test', NULL, NULL, NULL, 'Active');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES
    ('Old Project', 1, '2019-01-01', '2020-01-01', 50000),  -- удалится в задаче 16
    ('New Project', 2, '2023-05-01', '2024-01-01', 80000);  -- останется

--task b
INSERT INTO employees (first_name,last_name,department)
VALUES ('Ayaganov','Nursultan','IT');

INSERT INTO employees(first_name, last_name,department,salary,status)
VALUES ('Zorbaev','Arsen','IT',DEFAULT,DEFAULT);

INSERT INTO departments(dept_name, budget, manager_id)
VALUES
('IT',120000,1),
('HR',60000,2),
('Sales',90000,3);

INSERT INTO employees (first_name, last_name, hire_date, salary, department)
VALUES ('Sultankerey', 'Adil', CURRENT_DATE, 50000 * 1.1, 'HR');


CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

--part c
UPDATE employees
SET salary = salary * 1.1
WHERE salary IS NOT NULL;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
    and hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 then 'Management'
    When salary BETWEEN 50000 and 80000 THEN 'Senior'
    ELSE 'Junior'
END
WHERE salary IS NOT NULL;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name AND e.salary IS NOT NULL
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales'
  AND salary IS NOT NULL;

--part d
DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


DELETE FROM departments d
WHERE d.dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date <'2023-01-01'
RETURNING *;

--part e
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Nuller', 'Test', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

--task f
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alice', 'Brown', 'Finance', 55000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary +5000
WHERE department = 'IT'
RETURNING emp_id , salary - 5000 AS old_salary , salary AS new_salary;

DELETE FROM employees
WHERE hire_date <'2020-01-01'
RETURNING *;

--task g
INSERT INTO employees(first_name, last_name, department, salary, hire_date)
SELECT 'Unique','User','IT',60000,current_date
WHERE NOT EXISTS(
    SELECT 1 FROM employees WHERE first_name='Unique' AND last_name = 'User'

);

UPDATE employees e
SET salary = salary * CASE
                          WHEN (
                                   SELECT MAX(d.budget)
                                   FROM departments d
                                   WHERE d.dept_name = e.department
                               ) > 100000 THEN 1.1
                          ELSE 1.05
    END
WHERE salary IS NOT NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Bulk', 'One', 'IT', 50000, CURRENT_DATE),
    (
'Bulk', 'Two', 'Sales', 55000, CURRENT_DATE),
    ('Bulk', 'Three', 'HR', 60000, CURRENT_DATE),
    ('Bulk', 'Four', 'Finance', 45000, CURRENT_DATE),
    ('Bulk', 'Five', 'IT', 70000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.1
WHERE first_name LIKE 'Bulk%';

CREATE TABLE IF NOT EXISTS employee_archive AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND dept_id IN (
    SELECT d.dept_id
    FROM departments d
    WHERE (SELECT COUNT(*) FROM employees e WHERE e.department = d.dept_name) > 3
);
