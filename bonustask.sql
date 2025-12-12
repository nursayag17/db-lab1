--CREATE TABLES
CREATE TABLE customers(
                          customer_id BIGSERIAL PRIMARY KEY,
                          iin         CHAR(12) NOT NULL UNIQUE CHECK (iin ~ '^[0-9]{12}$'),
                          full_name   TEXT     NOT NULL,
                          phone       TEXT,
                          email       TEXT,
                          status      TEXT NOT NULL DEFAULT 'active'
                              CHECK (status IN ('active','blocked','frozen')),
                          created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          daily_limit_kzt NUMERIC(18,2) NOT NULL CHECK (daily_limit_kzt >= 0)
);

CREATE TABLE accounts (
                          account_id     BIGSERIAL PRIMARY KEY,
                          customer_id    BIGINT NOT NULL REFERENCES customers(customer_id),
                          account_number VARCHAR(34) NOT NULL UNIQUE CHECK (account_number ~ '^KZ[0-9]{18}$'),
                          currency       TEXT NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
                          balance        NUMERIC(18,2) NOT NULL CHECK (balance >= 0),
                          is_active      BOOLEAN NOT NULL DEFAULT TRUE,
                          opened_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          closed_at      TIMESTAMPTZ
);

CREATE TABLE transactions(
                             transaction_id  BIGSERIAL PRIMARY KEY,
                             from_account_id BIGINT NOT NULL REFERENCES accounts (account_id),
                             to_account_id   BIGINT NOT NULL REFERENCES accounts (account_id),
                             amount          NUMERIC(18,2) NOT NULL CHECK (amount > 0),
                             currency        TEXT NOT NULL CHECK (currency IN ('KZT','USD','EUR','RUB')),
                             exchange_rate   NUMERIC(18,6) NOT NULL CHECK (exchange_rate > 0),
                             amount_kzt      NUMERIC(18,2) NOT NULL CHECK (amount_kzt >= 0),
                             type            TEXT NOT NULL CHECK (type IN ('transfer','deposit','withdrawal')),
                             status          TEXT NOT NULL CHECK (status IN ('pending','completed','failed','reversed')),
                             created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                             completed_at    TIMESTAMPTZ,
                             description     TEXT NOT NULL
);

CREATE TABLE exchange_rates (
                                rate_id       BIGSERIAL PRIMARY KEY,
                                from_currency TEXT NOT NULL CHECK (from_currency IN ('KZT','USD','EUR','RUB')),
                                to_currency   TEXT NOT NULL CHECK (to_currency   IN ('KZT','USD','EUR','RUB')),
                                rate          NUMERIC(18,6) NOT NULL CHECK (rate > 0),
                                valid_from    TIMESTAMPTZ NOT NULL,
                                valid_to      TIMESTAMPTZ
);

CREATE TABLE audit_log (
                           log_id      BIGSERIAL PRIMARY KEY,
                           table_name  TEXT NOT NULL,
                           record_id   BIGINT,
                           action      TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
                           old_values  JSONB,
                           new_values  JSONB,
                           changed_by  TEXT,
                           changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                           ip_address  INET
);

--INSERT INTO TABLES
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt)
VALUES
    ('040515301245', 'Ayan Yerzhanuly',       '+77081234501', 'ayan.yerzan@gmail.com',      'active',   1500000),
    ('020911450982', 'Dias Mukhtar',          '+77079882214', 'dias.mukhtar02@mail.ru',     'active',   1000000),
    ('010203550134', 'Nursultan Ayanov',      '+77075550112', 'ns.ayanov@gmail.com',        'frozen',    500000),
    ('050422602355', 'Alina Kassym',          '+77087001034', 'alina_kassym@icloud.com',    'active',   2000000),
    ('990110402198', 'Miras Zhaksylykov',     '+77051230988', 'miras.zh99@gmail.com',       'blocked',   300000),
    ('030728301776', 'Dana Tolegenova',       '+77711123876', 'dana.tlg@mail.ru',           'active',    800000),
    ('041231450567', 'Ilyas Karim',           '+77082210045', 'ilyas_karim04@mail.ru',      'active',   2500000),
    ('070317602911', 'Zarina Tursyn',         '+77070091234', 'zarina_tursyn7@gmail.com',   'active',   1200000),
    ('021220350442', 'Ramazan Bekbol',        '+77073332012', 'ramazan_bekbol02@mail.ru',   'frozen',    400000),
    ('990905601201', 'Yerassyl Bakhyt',       '+77085559012', 'yerassyl_bahyt@gmail.com',   'active',   1800000);

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active)
VALUES
    (1,  'KZ735600123456789001', 'KZT', 350000.00, TRUE),
    (2,  'KZ215600987654321002', 'USD', 1200.50,   TRUE),
    (3,  'KZ445601555888121003', 'KZT', 50000.00,  TRUE),
    (4,  'KZ865601090909090004', 'EUR', 780.10,   TRUE),
    (5,  'KZ905601332211009005', 'KZT', 15000.00, FALSE),
    (6,  'KZ565601778899554006', 'USD', 220.00,   TRUE),
    (7,  'KZ195601123443210007', 'KZT', 980000.00, TRUE),
    (8,  'KZ325601090012340008', 'KZT', 410000.00, TRUE),
    (9,  'KZ555601006655441009', 'RUB', 13000.00,  TRUE),
    (10, 'KZ665601770012349010', 'KZT', 250000.00, TRUE);

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to)
VALUES
    ('USD', 'KZT', 475.20, '2025-01-01', NULL),
    ('EUR', 'KZT', 510.75, '2025-01-01', NULL),
    ('RUB', 'KZT', 5.20,  '2025-01-01', NULL),
    ('KZT', 'USD', 0.0021, '2025-01-01', NULL),
    ('KZT', 'EUR', 0.00196,'2025-01-01', NULL),
    ('KZT', 'RUB', 0.19,   '2025-01-01', NULL),
    ('USD', 'KZT', 470.10, '2024-12-01', '2024-12-31'),
    ('EUR', 'KZT', 505.00, '2024-12-01', '2024-12-31'),
    ('RUB', 'KZT', 5.10,   '2024-12-01', '2024-12-31'),
    ('USD', 'KZT', 468.30, '2024-11-01', '2024-11-30');

INSERT INTO transactions
(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description)
VALUES
    (1, 7,   5000.00, 'KZT', 1,       5000.00,  'transfer',  'completed', 'Transfer to Ilyas'),
    (2, 1,   100.00,  'USD', 475.20,  47520.00, 'transfer',  'completed', 'USD to Ayan'),
    (3, 4,   20000.00,'KZT', 1,       20000.00, 'transfer',  'failed',    'Insufficient balance'),
    (5, 3,   50.00,   'USD', 475.20,  23760.00, 'transfer',  'completed', 'Payment refund'),
    (6, 2,   10.00,   'USD', 475.20,  4752.00,  'transfer',  'completed', 'Test payment'),
    (7, 8,   30000.00,'KZT', 1,       30000.00, 'transfer',  'completed', 'Loan repayment'),
    (8, 6,   15000.00,'KZT', 1,       15000.00, 'withdrawal','completed', 'ATM withdrawal'),
    (9, 10,  500.00,  'RUB', 5.20,    2600.00,  'transfer',  'completed', 'Rub transfer'),
    (10, 1,  1200.00, 'KZT', 1,       1200.00,  'deposit',   'completed', 'Cash deposit'),
    (4, 9,   30.00,   'EUR', 510.75,  15322.50, 'transfer',  'pending',   'Pending transaction');

-- AUDIT TRIGGER INFRASTRUCTURE

CREATE OR REPLACE FUNCTION audit_trigger_fn(p_pk_column_name TEXT)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_record_id BIGINT;
    v_old       JSONB;
    v_new       JSONB;
    v_action    TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_action := 'INSERT';
        v_new    := to_jsonb(NEW);
        v_old    := NULL;
        v_record_id := (to_jsonb(NEW)->>p_pk_column_name)::BIGINT;
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := 'UPDATE';
        v_new    := to_jsonb(NEW);
        v_old    := to_jsonb(OLD);
        v_record_id := (to_jsonb(NEW)->>p_pk_column_name)::BIGINT;
    ELSIF TG_OP = 'DELETE' THEN
        v_action := 'DELETE';
        v_new    := NULL;
        v_old    := to_jsonb(OLD);
        v_record_id := (to_jsonb(OLD)->>p_pk_column_name)::BIGINT;
    END IF;

    INSERT INTO audit_log (
        table_name, record_id, action,
        old_values, new_values, changed_by, changed_at, ip_address
    )
    VALUES (
               TG_TABLE_NAME,
               v_record_id,
               v_action,
               v_old,
               v_new,
               current_user,
               NOW(),
               NULL
           );

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER customers_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON customers
    FOR EACH ROW
EXECUTE FUNCTION audit_trigger_fn('customer_id');

CREATE TRIGGER accounts_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON accounts
    FOR EACH ROW
EXECUTE FUNCTION audit_trigger_fn('account_id');

CREATE TRIGGER transactions_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON transactions
    FOR EACH ROW
EXECUTE FUNCTION audit_trigger_fn('transaction_id');

-- helper: explicit logging of failed transfer attempts
CREATE OR REPLACE FUNCTION log_transfer_attempt(
    p_from_account_number VARCHAR,
    p_to_account_number   VARCHAR,
    p_amount              NUMERIC(18,2),
    p_currency            TEXT,
    p_description         TEXT,
    p_status              TEXT,
    p_error_code          TEXT,
    p_error_message       TEXT
) RETURNS VOID
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO audit_log(
        table_name, record_id, action,
        old_values, new_values, changed_by
    )
    VALUES (
               'transactions',
               NULL,
               'INSERT',
               NULL,
               jsonb_build_object(
                       'from_account_number', p_from_account_number,
                       'to_account_number',   p_to_account_number,
                       'amount',              p_amount,
                       'currency',            p_currency,
                       'description',         p_description,
                       'status',              p_status,
                       'error_code',          p_error_code,
                       'error_message',       p_error_message
               ),
               current_user
           );
END;
$$;

-- TASK 1: TRANSACTION MANAGEMENT

CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_account_number VARCHAR,
    p_to_account_number   VARCHAR,
    p_amount              NUMERIC(18,2),
    p_currency            TEXT,
    p_description         TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_from_account_id     BIGINT;
    v_to_account_id       BIGINT;
    v_from_balance        NUMERIC(18,2);
    v_from_currency       TEXT;
    v_to_currency         TEXT;

    v_sender_customer_id  BIGINT;
    v_sender_status       TEXT;
    v_daily_limit_kzt     NUMERIC(18,2);

    v_exchange_rate_to_kzt NUMERIC(18,6);
    v_amount_kzt          NUMERIC(18,2);
    v_today_total_kzt     NUMERIC(18,2);

    v_rate_between        NUMERIC(18,6);
    v_tx_id               BIGINT;
BEGIN
    -- 1. Load and lock sender account
    SELECT a.account_id, a.balance, a.currency, a.customer_id
    INTO v_from_account_id, v_from_balance, v_from_currency, v_sender_customer_id
    FROM accounts a
    WHERE a.account_number = p_from_account_number
      AND a.is_active = TRUE
        FOR UPDATE;

    IF NOT FOUND THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1001', 'From account not found or inactive');
        RAISE EXCEPTION USING
            MESSAGE = 'From account not found or inactive',
            ERRCODE = 'P1001';
    END IF;

    -- 2. Load and lock receiver account
    SELECT a.account_id, a.currency
    INTO v_to_account_id, v_to_currency
    FROM accounts a
    WHERE a.account_number = p_to_account_number
      AND a.is_active = TRUE
        FOR UPDATE;

    IF NOT FOUND THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1002', 'To account not found or inactive');
        RAISE EXCEPTION USING
            MESSAGE = 'To account not found or inactive',
            ERRCODE = 'P1002';
    END IF;

    -- 3. Currency must match sender account currency
    IF p_currency <> v_from_currency THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1003', 'Currency does not match sender account');
        RAISE EXCEPTION USING
            MESSAGE = 'Currency does not match sender account',
            ERRCODE = 'P1003';
    END IF;

    -- 4. Check customer status and daily limit
    SELECT status, daily_limit_kzt
    INTO v_sender_status, v_daily_limit_kzt
    FROM customers
    WHERE customer_id = v_sender_customer_id;

    IF v_sender_status <> 'active' THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1004', 'Sender is not active');
        RAISE EXCEPTION USING
            MESSAGE = 'Sender is not active',
            ERRCODE = 'P1004';
    END IF;

    -- 5. Check balance
    IF v_from_balance < p_amount THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1005', 'Insufficient balance');
        RAISE EXCEPTION USING
            MESSAGE = 'Insufficient balance',
            ERRCODE = 'P1005';
    END IF;

    -- 6. Get rate to KZT for daily limit calculations
    SELECT rate
    INTO v_exchange_rate_to_kzt
    FROM exchange_rates
    WHERE from_currency = p_currency
      AND to_currency   = 'KZT'
      AND valid_from <= NOW()
      AND (valid_to IS NULL OR valid_to > NOW())
    ORDER BY valid_from DESC
    LIMIT 1;

    IF NOT FOUND THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1006', 'Exchange rate to KZT not found');
        RAISE EXCEPTION USING
            MESSAGE = 'Exchange rate to KZT not found',
            ERRCODE = 'P1006';
    END IF;

    v_amount_kzt := p_amount * v_exchange_rate_to_kzt;

    -- 7. Daily limit check (only completed transfers count)
    SELECT COALESCE(SUM(amount_kzt), 0)
    INTO v_today_total_kzt
    FROM transactions
    WHERE from_account_id = v_from_account_id
      AND created_at::date = NOW()::date
      AND status = 'completed';

    IF v_today_total_kzt + v_amount_kzt > v_daily_limit_kzt THEN
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1007', 'Daily limit exceeded');
        RAISE EXCEPTION USING
            MESSAGE = 'Daily limit exceeded',
            ERRCODE = 'P1007';
    END IF;

    -- 8. Rate between sender and receiver currencies
    IF v_from_currency = v_to_currency THEN
        v_rate_between := 1;
    ELSE
        SELECT rate
        INTO v_rate_between
        FROM exchange_rates
        WHERE from_currency = v_from_currency
          AND to_currency   = v_to_currency
          AND valid_from <= NOW()
          AND (valid_to IS NULL OR valid_to > NOW())
        ORDER BY valid_from DESC
        LIMIT 1;

        IF NOT FOUND THEN
            PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                         p_amount, p_currency, p_description,
                                         'failed', 'P1008', 'Exchange rate between currencies not found');
            RAISE EXCEPTION USING
                MESSAGE = 'Exchange rate between currencies not found',
                ERRCODE = 'P1008';
        END IF;
    END IF;

    -- 9. SAVEPOINT and balance update
    SAVEPOINT start_tx;

    BEGIN
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = v_from_account_id;

        UPDATE accounts
        SET balance = balance + (p_amount * v_rate_between)
        WHERE account_id = v_to_account_id;

        INSERT INTO transactions (
            from_account_id, to_account_id, amount, currency,
            exchange_rate, amount_kzt, type, status, description, completed_at
        )
        VALUES (
                   v_from_account_id, v_to_account_id, p_amount,
                   p_currency, v_exchange_rate_to_kzt, v_amount_kzt,
                   'transfer', 'completed', p_description, NOW()
               )
        RETURNING transaction_id INTO v_tx_id;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT start_tx;
        PERFORM log_transfer_attempt(p_from_account_number, p_to_account_number,
                                     p_amount, p_currency, p_description,
                                     'failed', 'P1099', 'Unexpected error during balance update');
        RAISE EXCEPTION USING
            MESSAGE = 'Unexpected error during balance update',
            ERRCODE = 'P1099';
    END;
END;
$$;

-- TASK 2: Views for Reporting

CREATE OR REPLACE VIEW latest_rates_to_kzt AS
SELECT DISTINCT ON (from_currency)
    from_currency,
    rate
FROM exchange_rates
WHERE to_currency = 'KZT'
ORDER BY from_currency, valid_from DESC;

-- 2.1 customer_balance_summary
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH per_account AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.daily_limit_kzt,
        a.currency,
        a.balance
    FROM customers c
             JOIN accounts a ON a.customer_id = c.customer_id
),
     per_currency AS (
         SELECT
             customer_id,
             full_name,
             daily_limit_kzt,
             currency,
             SUM(balance) AS total_balance
         FROM per_account
         GROUP BY customer_id, full_name, daily_limit_kzt, currency
     ),
     with_kzt AS (
         SELECT
             pc.customer_id,
             pc.full_name,
             pc.currency,
             pc.daily_limit_kzt,
             pc.total_balance,
             pc.total_balance * COALESCE(lr.rate, 1) AS total_balance_kzt
         FROM per_currency pc
                  LEFT JOIN latest_rates_to_kzt lr
                            ON pc.currency = lr.from_currency
     ),
     per_customer AS (
         SELECT
             customer_id,
             full_name,
             daily_limit_kzt,
             SUM(total_balance_kzt) AS customer_total_kzt
         FROM with_kzt
         GROUP BY customer_id, full_name, daily_limit_kzt
     )
SELECT
    w.customer_id,
    w.full_name,
    w.currency,
    w.total_balance,
    w.total_balance_kzt,
    pc.customer_total_kzt,
    CASE
        WHEN pc.daily_limit_kzt = 0 THEN NULL
        ELSE ROUND(100 * pc.customer_total_kzt / pc.daily_limit_kzt, 2)
        END AS daily_limit_usage_percent,
    RANK() OVER (ORDER BY pc.customer_total_kzt DESC) AS balance_rank
FROM with_kzt w
         JOIN per_customer pc USING (customer_id)
ORDER BY balance_rank, w.currency;

-- 2.2 daily_transaction_report
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH per_day AS (
    SELECT
        t.created_at::date AS transaction_date,
        t.type,
        t.currency,
        COUNT(*)        AS tx_count,
        SUM(t.amount)   AS total_amount,
        SUM(t.amount_kzt) AS total_amount_kzt,
        AVG(t.amount_kzt) AS avg_amount_kzt
    FROM transactions t
    WHERE t.status = 'completed'
    GROUP BY t.created_at::date, t.type, t.currency
)
SELECT
    transaction_date,
    type,
    currency,
    tx_count,
    total_amount,
    total_amount_kzt,
    avg_amount_kzt,
    SUM(total_amount_kzt) OVER (
        ORDER BY transaction_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_kzt,
    LAG(total_amount_kzt) OVER (ORDER BY transaction_date) AS prev_day_total_kzt,
    CASE
        WHEN LAG(total_amount_kzt) OVER (ORDER BY transaction_date) IS NULL
            OR LAG(total_amount_kzt) OVER (ORDER BY transaction_date) = 0
            THEN NULL
        ELSE ROUND(
                100 * (total_amount_kzt -
                       LAG(total_amount_kzt) OVER (ORDER BY transaction_date))
                    / NULLIF(LAG(total_amount_kzt) OVER (ORDER BY transaction_date), 0),
                2
             )
        END AS day_over_day_growth_percent
FROM per_day
ORDER BY transaction_date, type, currency;

-- 2.3 suspicious_activity_view
CREATE OR REPLACE VIEW suspicious_activity_view
            WITH (security_barrier = true) AS
WITH base AS (
    SELECT
        t.*,
        COUNT(*) OVER (
            PARTITION BY t.from_account_id,
                t.created_at::date
            ) AS daily_tx_count,
        COUNT(*) OVER (
            PARTITION BY t.from_account_id,
                t.to_account_id,
                date_trunc('hour', t.created_at)
            ) AS hourly_pair_count,
        LAG(t.created_at) OVER (
            PARTITION BY t.from_account_id
            ORDER BY t.created_at
            ) AS prev_tx_time
    FROM transactions t
)
SELECT
    b.*,
    CASE
        WHEN b.amount_kzt > 5000000 THEN 'HIGH_AMOUNT'
        WHEN b.hourly_pair_count > 10 THEN 'MANY_TRANSFERS_SAME_HOUR'
        WHEN b.prev_tx_time IS NOT NULL
            AND b.created_at - b.prev_tx_time < INTERVAL '1 minute'
            THEN 'RAPID_SEQUENCE'
        ELSE 'NORMAL'
        END AS suspicious_reason
FROM base b
WHERE
    b.amount_kzt > 5000000
   OR b.hourly_pair_count > 10
   OR (b.prev_tx_time IS NOT NULL AND b.created_at - b.prev_tx_time < INTERVAL '1 minute')
ORDER BY b.created_at DESC;

--Task 3: Performance Optimization with Indexes
CREATE INDEX IF NOT EXISTS idx_customers_iin_btree
    ON customers USING btree(iin);

CREATE INDEX IF NOT EXISTS idx_customers_status
    ON customers(status);

CREATE INDEX IF NOT EXISTS idx_accounts_account_number
    ON accounts(account_number);
CREATE INDEX IF NOT EXISTS idx_accounts_active_customer
    ON accounts(customer_id, currency)
    WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_customers_email_lower
    ON customers(LOWER(email));
CREATE INDEX IF NOT EXISTS idx_customers_phone_hash
    ON customers USING hash(phone);
CREATE INDEX IF NOT EXISTS idx_transactions_from_account_date
    ON transactions(from_account_id, created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_status_created
    ON transactions(status, created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_daily_report
    ON transactions(created_at, type, currency)
    INCLUDE (amount_kzt, amount);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_pair_valid
    ON exchange_rates(from_currency, to_currency, valid_from DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_new_values_gin
    ON audit_log USING GIN (new_values);

--Example
EXPLAIN ANALYZE
SELECT * FROM accounts
WHERE account_number = 'KZ735600123456789001';

EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE from_account_id = 1 AND created_at::date = NOW()::date AND status = 'completed';

EXPLAIN ANALYZE
SELECT * FROM customer_balance_summary;

--Task 4: Advanced Procedure - Batch Processing
CREATE TABLE salary_payments (
                                 salary_id           BIGSERIAL PRIMARY KEY,
                                 batch_id            BIGINT NOT NULL,
                                 employee_name       TEXT   NOT NULL,
                                 from_account_number VARCHAR(34) NOT NULL,
                                 to_account_number   VARCHAR(34) NOT NULL,
                                 amount              NUMERIC(18,2) NOT NULL CHECK (amount > 0),
                                 currency            TEXT NOT NULL CHECK (currency IN ('KZT','USD','EUR','RUB')),
                                 description         TEXT,
                                 status              TEXT NOT NULL DEFAULT 'pending'
                                     CHECK (status IN ('pending','processed','failed')),
                                 error_message       TEXT,
                                 created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                 processed_at        TIMESTAMPTZ
);

CREATE OR REPLACE PROCEDURE process_salary_batch(
    p_batch_id        BIGINT,
    OUT successful_count INT,
    OUT failed_count     INT,
    OUT failed_details   JSONB
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_payment      salary_payments%ROWTYPE;
    v_company_account VARCHAR(34);
    v_total_amount NUMERIC(18,2);
    v_company_balance NUMERIC(18,2);
BEGIN
    successful_count := 0;
    failed_count     := 0;
    failed_details   := '[]'::JSONB;

    SELECT from_account_number, SUM(amount)
    INTO v_company_account, v_total_amount
    FROM salary_payments
    WHERE batch_id = p_batch_id
    GROUP BY from_account_number;

    IF v_company_account IS NULL THEN
        RAISE EXCEPTION USING
            MESSAGE = 'No salary payments found for batch',
            ERRCODE = 'P2001';
    END IF;

    -- check company balance before processing
    SELECT balance
    INTO v_company_balance
    FROM accounts
    WHERE account_number = v_company_account
      AND is_active = TRUE
        FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            MESSAGE = 'Company account for batch not found or inactive',
            ERRCODE = 'P2002';
    END IF;

    IF v_company_balance < v_total_amount THEN
        RAISE EXCEPTION USING
            MESSAGE = 'Insufficient company balance for whole salary batch',
            ERRCODE = 'P2003';
    END IF;

    BEGIN
        PERFORM pg_advisory_lock(p_batch_id);

        FOR v_payment IN
            SELECT *
            FROM salary_payments
            WHERE batch_id = p_batch_id
              AND status = 'pending'
                FOR UPDATE
            LOOP
                SAVEPOINT before_single_payment;

                BEGIN
                    UPDATE customers c
                    SET daily_limit_kzt = daily_limit_kzt + v_payment.amount * COALESCE(lr.rate,1)
                    FROM accounts a
                             LEFT JOIN latest_rates_to_kzt lr ON lr.from_currency = v_payment.currency
                    WHERE a.account_number = v_payment.from_account_number
                      AND a.customer_id = c.customer_id;

                    CALL process_transfer(
                            v_payment.from_account_number,
                            v_payment.to_account_number,
                            v_payment.amount,
                            v_payment.currency,
                            COALESCE(v_payment.description, 'Salary payment')
                         );

                    UPDATE salary_payments
                    SET status       = 'processed',
                        error_message = NULL,
                        processed_at  = NOW()
                    WHERE salary_id = v_payment.salary_id;

                    successful_count := successful_count + 1;

                EXCEPTION WHEN OTHERS THEN
                    ROLLBACK TO SAVEPOINT before_single_payment;

                    UPDATE salary_payments
                    SET status        = 'failed',
                        error_message = SQLERRM,
                        processed_at  = NOW()
                    WHERE salary_id = v_payment.salary_id;

                    failed_count := failed_count + 1;

                    failed_details := failed_details || jsonb_build_object(
                            'salary_id',      v_payment.salary_id,
                            'employee_name',  v_payment.employee_name,
                            'from_account',   v_payment.from_account_number,
                            'to_account',     v_payment.to_account_number,
                            'amount',         v_payment.amount,
                            'currency',       v_payment.currency,
                            'error',          SQLERRM
                                                        );
                END;
            END LOOP;

        PERFORM pg_advisory_unlock(p_batch_id);

    EXCEPTION WHEN OTHERS THEN
        PERFORM pg_advisory_unlock(p_batch_id);
        RAISE;
    END;
END;
$$;

-- Example
INSERT INTO salary_payments (
    batch_id, employee_name, from_account_number,
    to_account_number, amount, currency, description
) VALUES
      (1, 'Employee 1', 'KZ735600123456789001', 'KZ195601123443210007', 150000.00, 'KZT', 'Monthly salary'),
      (1, 'Employee 2', 'KZ735600123456789001', 'KZ325601090012340008', 120000.00, 'KZT', 'Monthly salary'),
      (1, 'Employee 3', 'KZ735600123456789001', 'KZ665601770012349010',  95000.00, 'KZT', 'Monthly salary');
