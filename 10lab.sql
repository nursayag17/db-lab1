--task 3.1
CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);
INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);
--3.2
BEGIN;
UPDATE accounts SET balance = balance -100
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100
    WHERE name = 'Bob';
COMMIT ;
--a) after transaction Alice balance is 900 , Bob balance is 1100
--b)Because transferring money is one logical operation that must be completed fully or not at all.
--c)If there is no transaction, the first UPDATE would already be permanently saved, while the second UPDATE would never happen
--3.3
BEGIN;
UPDATE accounts SET balance = balance - 500
    where name = 'Alice';

SELECT * from accounts WHERE name = 'Alice';

ROLLBACK;
SELECT * from accounts WHERE name = 'Alice';
--a) 500
--b) 1000
--c)ROLLBACK is used to avoid saving incorrect or incomplete changes and keep the database consistent.
--3.4
BEGIN;
UPDATE accounts SET balance = balance - 100
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE  accounts SET balance = balance + 100
    WHERE name = 'Bob';
ROLLBACK  to my_savepoint;
UPDATE accounts SET balance = balance + 100
    WHERE name = 'Wally';
COMMIT;
--A)After COMMIT Alice has 900, Bob remains unchanged, and Wally has 850
--b) Bob was credited temporarily but his update was undone because the ROLLBACK TO SAVEPOINT canceled it
--c) SAVEPOINT lets you undo only part of a transaction instead of starting the whole transaction over
--3.5
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
--a) In READ COMMITTED, Terminal 1 sees original data first (Coke, Pepsi) and after Terminal 2 commits it sees the new data (Fanta).
--b) In SERIALIZABLE, Terminal 1 sees only the original data (Coke, Pepsi), even after Terminal 2 commits.
--c) READ COMMITTED allows seeing committed changes from other transactions, while SERIALIZABLE prevents this and makes transactions behave as if they run one after another.

--3.6
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;

BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
--3.7
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;

--ex 4.1
BEGIN;

-- Check Bob's balance
SELECT balance FROM accounts WHERE name = 'Bob';

-- Only transfer if Bob has enough money
UPDATE accounts
SET balance = balance - 200
WHERE name = 'Bob'
  AND balance >= 200;
IF FOUND THEN
    UPDATE accounts
    SET balance = balance + 200
    WHERE name = 'Wally';
ELSE
    ROLLBACK;
    RAISE NOTICE 'Transfer failed: insufficient funds';
    RETURN;
END IF;

COMMIT;

--4.2
BEGIN;

-- Insert new product
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'TestProduct', 5.00);

SAVEPOINT sp1;

-- Update price
UPDATE products
SET price = 7.00
WHERE product = 'TestProduct';

SAVEPOINT sp2;

-- Delete product
DELETE FROM products
WHERE product = 'TestProduct';

-- Roll back to first savepoint (sp1)
ROLLBACK TO sp1;

COMMIT;

-- Check final state
SELECT * FROM products WHERE product = 'TestProduct';

--4.3
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE name = 'Alice';

UPDATE accounts
SET balance = balance - 300
WHERE name = 'Alice';

-- Wait…
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE name = 'Alice';

UPDATE accounts
SET balance = balance - 300
WHERE name = 'Alice';

COMMIT;


--4.4
SELECT MAX(price) FROM sells WHERE shop='Joe''s Shop';
-- Joe changes price here
SELECT MIN(price) FROM sells WHERE shop='Joe''s Shop';

BEGIN;

SELECT MAX(price), MIN(price)
FROM sells
WHERE shop='Joe''s Shop';

COMMIT;
