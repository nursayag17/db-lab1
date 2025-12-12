
--1.1
UPDATE accounts SET balance = balance - 20000 WHERE account_id = 1; --330000
UPDATE accounts SET balance = balance + 20000 WHERE account_id = 3;--70000
--1.2
--The required ACID property is Atomicity.
--1.3
--If a system crash occurs between the two UPDATE statements, the balances become inconsistent because only one of the updates would be applied. This violates Atomicity.
--2.1
--Yes, the record still exists after all commands.
--2.2
--The status of the record is completed.
--2.3
--Because ROLLBACK TO SAVEPOINT cancels all operations performed after the savepoint, including the DELETE.
--3.1
--Query A returns 980,000 KZT.
--3.2
--Query B returns 1,030,000 KZT.
--3.3
--Because under the READ COMMITTED isolation level, each SELECT sees the most recently committed data, so the second SELECT observes the committed update from the other transaction.
--3.4
--This anomaly is called Non-repeatable read.