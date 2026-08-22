-- Schema for the Czech Bank (Berka) dataset
-- Data source: https://sorry.vse.cz/~berka/challenge/pkdd1999/berka.htm
-- (mirrored on Kaggle: kaggle.com/datasets/marceloventura/the-berka-dataset)
--
-- district's columns were renamed from the raw dataset's cryptic codes
-- (A1-A16) to readable names for this project. Mapping:
-- A1 district_id | A2 dname | A3 region | A4 pop | A5 nmu500 | A6 nmu2k
-- A7 nmu10k | A8 nmuinf | A9 ncit | A10 rurba | A11 avgsal | A12 urat95
-- A13 urat96 | A14 ent_ppt | A15 ncri95 | A16 ncri96

CREATE TABLE account (
    account_id INTEGER,
    district_id INTEGER,
    frequency TEXT,
    date INTEGER
);

CREATE TABLE client (
    client_id INTEGER,
    birth_number TEXT,
    district_id INTEGER
);

CREATE TABLE disp (
    disp_id INTEGER,
    client_id INTEGER,
    account_id INTEGER,
    type TEXT          -- 'OWNER' or 'DISPONENT'
);

CREATE TABLE district (
    district_id INTEGER,
    dname TEXT,
    region TEXT,
    pop INTEGER,
    nmu500 INTEGER,     -- no. of municipalities, pop < 499
    nmu2k INTEGER,      -- no. of municipalities, pop 500-1999
    nmu10k INTEGER,     -- no. of municipalities, pop 2000-9999
    nmuinf INTEGER,     -- no. of municipalities, pop > 10000
    ncit INTEGER,       -- no. of cities
    rurba REAL,         -- ratio of urban inhabitants
    avgsal INTEGER,     -- average salary
    urat95 TEXT,        -- unemployment rate '95
    urat96 REAL,        -- unemployment rate '96
    ent_ppt INTEGER,    -- entrepreneurs per 1000 inhabitants
    ncri95 TEXT,        -- no. of committed crimes '95
    ncri96 INTEGER      -- no. of committed crimes '96
);

CREATE TABLE loan (
    loan_id INTEGER,
    account_id INTEGER,
    date INTEGER,
    amount INTEGER,
    duration INTEGER,
    payments REAL,
    status TEXT         -- A = finished OK, B = finished/defaulted,
                         -- C = running OK, D = running/in debt
);

CREATE TABLE card (
    card_id INTEGER,
    disp_id INTEGER,
    type TEXT,           -- junior / classic / gold
    issued TEXT
);

CREATE TABLE order_t (   -- 'order' is a reserved SQL keyword
    order_id INTEGER,
    account_id INTEGER,
    bank_to TEXT,
    account_to TEXT,
    amount REAL,
    k_symbol TEXT
);

CREATE TABLE trans (
    trans_id INTEGER,
    account_id INTEGER,
    date INTEGER,
    type TEXT,            -- PRIJEM = credit, VYDAJ = withdrawal
    operation TEXT,
    amount REAL,
    balance REAL,
    k_symbol TEXT,
    bank TEXT,
    account TEXT
);
