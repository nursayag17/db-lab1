--task 1.1
CREATE TABLE employees (
                           employee_id INT,
                           first_name TEXT,
                           last_name TEXT,
                           age INT CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);
INSERT INTO employees VALUES (1, 'Nuts', 'Ayag', 25, 3500);
INSERT INTO employees VALUES (2, 'Arys', 'Zhap', 45, 5000);
--task 1.2
CREATE TABLE products_catalog (
                                  product_id INT,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0 AND
                                      discount_price > 0 AND
                                      discount_price < regular_price
                                      )
);
INSERT INTO products_catalog VALUES (1, 'Ноутбук HP Pavilion', 380000, 349000);
INSERT INTO products_catalog VALUES (2, 'Смартфон Samsung A55', 250000, 230000);

-- task 1.3
CREATE TABLE bookings (
                          booking_id INT,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INT,
                          CHECK (num_guests BETWEEN 1 AND 10),
                          CHECK (check_out_date > check_in_date)
);
--task 1.4
INSERT INTO employees VALUES (5, 'Damir', 'Kenzhebayev', 28, 420000);
INSERT INTO products_catalog VALUES (5, 'Телевизор LG 4K', 420000, 390000);
INSERT INTO bookings VALUES (5, '2025-09-10', '2025-09-15', 3);
SELECT * FROM employees;
SELECT * FROM products_catalog;
SELECT * FROM bookings;

--task 2.1
CREATE TABLE customers (
                           customer_id INT NOT NULL,
                           email TEXT NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);
--task 2.2
CREATE TABLE inventory (
                           item_id INT NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INT NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);
--task 2.3
INSERT INTO customers VALUES (5, 'dias@mail.kz', NULL, '2025-04-05');
INSERT INTO inventory VALUES (6, 'Колонка JBL', 10, 60000, '2025-05-05 10:00:00');
SELECT * FROM customers;
SELECT * FROM inventory;
--task 3.1
CREATE TABLE users (
                       user_id INT,
                       username TEXT UNIQUE,
                       email TEXT UNIQUE,
                       created_at TIMESTAMP
);
--task 3.2
CREATE TABLE course_enrollments (
                                    enrollment_id INT,
                                    student_id INT,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

--task 3.3
DROP TABLE IF EXISTS users;

CREATE TABLE users (
                       user_id INT,
                       username TEXT,
                       email TEXT,
                       created_at TIMESTAMP,
                       CONSTRAINT unique_username UNIQUE (username),
                       CONSTRAINT unique_email UNIQUE (email)
);

--task 4.1
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

--task 4.2
CREATE TABLE student_courses (
                                 student_id INT,
                                 course_id INT,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 PRIMARY KEY (student_id, course_id)
);
--task 4.3
-- PRIMARY KEY is a combination of UNIQUE and NOT NULL.
-- This means every record must have a unique and non-null value in that column.
-- UNIQUE allows NULL values, while PRIMARY KEY does not.
-- Also, a table can have only one PRIMARY KEY,
-- but it can contain multiple UNIQUE constraints.

-- - Single-column PRIMARY KEY:
--   Used when one column is enough to uniquely identify each record.
--   Example: dept_id in the departments table.
--
-- - Composite PRIMARY KEY:
--   Used when the unique identity of a row depends on more than one column.
--   Example: (student_id, course_id) in the student_courses table.

-- The PRIMARY KEY acts as the main unique identifier for each row.
-- Having more than one would make it unclear which one defines the record.
--
-- However, you can have multiple UNIQUE constraints
-- to enforce uniqueness on other columns (e.g., email, username).

--task 5.1
CREATE TABLE employees_dept (
                                emp_id INT PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INT REFERENCES departments(dept_id),
                                hire_date DATE
);
--task 5.2
CREATE TABLE authors (
                         author_id INT PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INT PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INT PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INT REFERENCES authors(author_id),
                       publisher_id INT REFERENCES publishers(publisher_id),
                       publication_year INT,
                       isbn TEXT UNIQUE
);
--task 5.3
CREATE TABLE authors (
                         author_id INT PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INT PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INT PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INT REFERENCES authors(author_id),
                       publisher_id INT REFERENCES publishers(publisher_id),
                       publication_year INT,
                       isbn TEXT UNIQUE
);

--task 5.2
CREATE TABLE categories (
                            category_id INT PRIMARY KEY,
                            category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
                             product_id INT PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INT REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
                        order_id INT PRIMARY KEY,
                        order_date DATE NOT NULL
);
CREATE TABLE order_items (
                             item_id INT PRIMARY KEY,
                             order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
                             product_id INT REFERENCES products_fk(product_id),
                             quantity INT CHECK (quantity > 0)
);
--task 6.1
CREATE TABLE customers (
                           customer_id SERIAL PRIMARY KEY,
                           name TEXT NOT NULL,
                           email TEXT UNIQUE NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);
CREATE TABLE products (
                          product_id SERIAL PRIMARY KEY,
                          name TEXT NOT NULL,
                          description TEXT,
                          price NUMERIC NOT NULL CHECK (price >= 0),
                          stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);
CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
                        order_date DATE NOT NULL,
                        total_amount NUMERIC CHECK (total_amount >= 0),
                        status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
CREATE TABLE order_details (
                               order_detail_id SERIAL PRIMARY KEY,
                               order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
                               product_id INT REFERENCES products(product_id),
                               quantity INT NOT NULL CHECK (quantity > 0),
                               unit_price NUMERIC NOT NULL CHECK (unit_price > 0)
);
