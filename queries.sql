-- =========================================================
-- BASIC: SELECT + WHERE
-- =========================================================

-- 1. Loans currently in debt (highest risk, active problem accounts)
SELECT loan_id, account_id, amount, duration, status
FROM loan
WHERE status = 'D'
ORDER BY amount DESC;

-- 2. Large cash withdrawals in 1998 (over 10,000 CZK)
SELECT trans_id, account_id, date, type, operation, amount
FROM trans
WHERE type = 'VYDAJ'
  AND amount > 10000
  AND date BETWEEN 980101 AND 981231
ORDER BY amount DESC
LIMIT 20;

-- =========================================================
-- INTERMEDIATE: GROUP BY + HAVING
-- =========================================================

-- 3. Loan count and total exposure by status
SELECT status,
       COUNT(*) AS num_loans,
       SUM(amount) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount
FROM loan
GROUP BY status
ORDER BY total_amount DESC;

-- 4. Districts with more than 15 loans issued (loan officer workload / exposure by region)
SELECT d.district_id, d.dname, d.region, COUNT(l.loan_id) AS num_loans
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN district d ON a.district_id = d.district_id
GROUP BY d.district_id, d.dname, d.region
HAVING COUNT(l.loan_id) > 15
ORDER BY num_loans DESC;

-- =========================================================
-- CASE WHEN
-- =========================================================

-- 5. Bucket every loan into a plain-English risk flag
SELECT loan_id, account_id, amount, status,
  CASE
    WHEN status IN ('A', 'C') THEN 'Good standing'
    WHEN status = 'D' THEN 'Currently in debt'
    WHEN status = 'B' THEN 'Defaulted'
  END AS risk_flag
FROM loan
ORDER BY amount DESC
LIMIT 20;

-- 6. Bucket loan amount into size tiers, then see how each tier performs
SELECT
  CASE
    WHEN amount < 50000 THEN 'Small (<50k)'
    WHEN amount < 150000 THEN 'Medium (50k-150k)'
    WHEN amount < 300000 THEN 'Large (150k-300k)'
    ELSE 'Very large (300k+)'
  END AS loan_size_tier,
  COUNT(*) AS num_loans,
  SUM(CASE WHEN status IN ('B','D') THEN 1 ELSE 0 END) AS num_risky,
  ROUND(100.0 * SUM(CASE WHEN status IN ('B','D') THEN 1 ELSE 0 END) / COUNT(*), 1) AS risky_pct
FROM loan
GROUP BY loan_size_tier
ORDER BY MIN(amount);

-- =========================================================
-- JOINS
-- =========================================================

-- 7. Client's home district demographics next to their account info
SELECT c.client_id, c.district_id, d.dname, d.region, d.avgsal, a.account_id, a.frequency
FROM client c
JOIN disp di ON c.client_id = di.client_id AND di.type = 'OWNER'
JOIN account a ON di.account_id = a.account_id
JOIN district d ON c.district_id = d.district_id
LIMIT 20;

-- 8. Average loan amount by region (join loan -> account -> district)
SELECT d.region,
       COUNT(l.loan_id) AS num_loans,
       ROUND(AVG(l.amount), 2) AS avg_loan_amount,
       ROUND(AVG(d.avgsal), 2) AS avg_district_salary
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN district d ON a.district_id = d.district_id
GROUP BY d.region
ORDER BY avg_loan_amount DESC;

-- 9. Customers who hold BOTH a loan and a credit card (cross-sell / relationship value)
SELECT DISTINCT c.client_id, l.loan_id, l.amount AS loan_amount, cd.type AS card_type
FROM client c
JOIN disp di ON c.client_id = di.client_id
JOIN account a ON di.account_id = a.account_id
JOIN loan l ON l.account_id = a.account_id
JOIN card cd ON cd.disp_id = di.disp_id
ORDER BY l.amount DESC;

-- =========================================================
-- WINDOW FUNCTIONS: RANK() / PARTITION BY
-- =========================================================

-- 10. Rank every loan by amount within its own status group
SELECT loan_id, account_id, status, amount,
       RANK() OVER (PARTITION BY status ORDER BY amount DESC) AS rank_within_status
FROM loan
ORDER BY status, rank_within_status
LIMIT 30;

-- 11. Rank districts by average salary within each region
SELECT district_id, dname, region, avgsal,
       RANK() OVER (PARTITION BY region ORDER BY avgsal DESC) AS salary_rank_in_region
FROM district
ORDER BY region, salary_rank_in_region;

-- 12. Top 3 highest loans per region (classic "top N per group" pattern, subquery instead of CTE)
SELECT region, loan_id, amount, rnk
FROM (
  SELECT d.region, l.loan_id, l.amount,
         RANK() OVER (PARTITION BY d.region ORDER BY l.amount DESC) AS rnk
  FROM loan l
  JOIN account a ON l.account_id = a.account_id
  JOIN district d ON a.district_id = d.district_id
)
WHERE rnk <= 3
ORDER BY region, rnk;
