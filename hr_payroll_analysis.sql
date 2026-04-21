-- ============================================================
-- HR Payroll & Attrition Analysis
-- Author: Ronak Parikh
-- Tools: SQL (MySQL / SQLite compatible), Python for visualization
-- Domain: HR Analytics / Payroll Administration
-- Goal: Analyze workforce costs, payroll trends, and employee
--       attrition drivers using SQL.
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. SCHEMA CREATION
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS departments (
    dept_id     INT PRIMARY KEY,
    dept_name   VARCHAR(50) NOT NULL,
    dept_head   VARCHAR(100),
    budget      DECIMAL(12,2)
);

CREATE TABLE IF NOT EXISTS employees (
    emp_id          INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    dept_id         INT,
    job_title       VARCHAR(100),
    hire_date       DATE,
    termination_date DATE,
    status          VARCHAR(20),  -- Active / Terminated
    gender          VARCHAR(10),
    age             INT,
    province        VARCHAR(50),
    education       VARCHAR(50),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE IF NOT EXISTS payroll (
    payroll_id      INT PRIMARY KEY,
    emp_id          INT,
    pay_period      DATE,       -- First day of pay period
    gross_pay       DECIMAL(10,2),
    net_pay         DECIMAL(10,2),
    tax_deducted    DECIMAL(10,2),
    cpp_deducted    DECIMAL(10,2),   -- Canada Pension Plan
    ei_deducted     DECIMAL(10,2),   -- Employment Insurance
    overtime_pay    DECIMAL(10,2),
    bonus           DECIMAL(10,2),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

CREATE TABLE IF NOT EXISTS performance (
    review_id       INT PRIMARY KEY,
    emp_id          INT,
    review_year     INT,
    rating          INT,        -- 1 (Poor) to 5 (Excellent)
    manager_comment TEXT,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


-- ─────────────────────────────────────────────
-- 2. BUSINESS QUERIES
-- ─────────────────────────────────────────────

-- ─── Q1: Total Payroll Cost by Department (YTD) ───
SELECT
    d.dept_name,
    COUNT(DISTINCT p.emp_id)             AS headcount,
    SUM(p.gross_pay)                     AS total_gross_pay,
    SUM(p.net_pay)                       AS total_net_pay,
    SUM(p.tax_deducted)                  AS total_tax,
    SUM(p.cpp_deducted + p.ei_deducted)  AS total_statutory_deductions,
    SUM(p.bonus)                         AS total_bonuses,
    ROUND(AVG(p.gross_pay), 2)           AS avg_gross_per_period
FROM payroll p
JOIN employees e ON p.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE p.pay_period >= DATE_FORMAT(CURDATE(), '%Y-01-01')  -- YTD
  AND e.status = 'Active'
GROUP BY d.dept_name
ORDER BY total_gross_pay DESC;


-- ─── Q2: Monthly Payroll Trend ───
SELECT
    DATE_FORMAT(pay_period, '%Y-%m') AS pay_month,
    COUNT(DISTINCT emp_id)            AS employees_paid,
    SUM(gross_pay)                    AS total_gross,
    SUM(overtime_pay)                 AS total_overtime,
    SUM(bonus)                        AS total_bonuses,
    ROUND(SUM(overtime_pay)/SUM(gross_pay)*100, 2) AS overtime_pct
FROM payroll
GROUP BY pay_month
ORDER BY pay_month;


-- ─── Q3: Attrition Rate by Department (Last 12 Months) ───
SELECT
    d.dept_name,
    COUNT(e.emp_id)                                          AS total_employees,
    SUM(CASE WHEN e.status = 'Terminated'
             AND e.termination_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
             THEN 1 ELSE 0 END)                              AS terminations_12m,
    ROUND(
        SUM(CASE WHEN e.status = 'Terminated'
                 AND e.termination_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
                 THEN 1 ELSE 0 END) * 100.0 / COUNT(e.emp_id),
    2)                                                       AS attrition_rate_pct
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY attrition_rate_pct DESC;


-- ─── Q4: Attrition by Tenure Band ───
SELECT
    CASE
        WHEN DATEDIFF(IFNULL(termination_date, CURDATE()), hire_date) / 365 < 1 THEN 'Under 1 Year'
        WHEN DATEDIFF(IFNULL(termination_date, CURDATE()), hire_date) / 365 < 3 THEN '1–3 Years'
        WHEN DATEDIFF(IFNULL(termination_date, CURDATE()), hire_date) / 365 < 5 THEN '3–5 Years'
        ELSE '5+ Years'
    END                         AS tenure_band,
    COUNT(*)                    AS total_employees,
    SUM(CASE WHEN status = 'Terminated' THEN 1 ELSE 0 END) AS terminated,
    ROUND(
        SUM(CASE WHEN status = 'Terminated' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2)                          AS attrition_rate_pct
FROM employees
GROUP BY tenure_band
ORDER BY attrition_rate_pct DESC;


-- ─── Q5: Gender Pay Gap Analysis ───
SELECT
    e.gender,
    d.dept_name,
    COUNT(DISTINCT e.emp_id)        AS headcount,
    ROUND(AVG(p.gross_pay * 26), 2) AS avg_annual_salary,   -- bi-weekly × 26
    ROUND(MIN(p.gross_pay * 26), 2) AS min_annual_salary,
    ROUND(MAX(p.gross_pay * 26), 2) AS max_annual_salary
FROM employees e
JOIN payroll p ON e.emp_id = p.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.status = 'Active'
  AND p.pay_period = (SELECT MAX(pay_period) FROM payroll)  -- Latest period only
GROUP BY e.gender, d.dept_name
ORDER BY d.dept_name, e.gender;


-- ─── Q6: High Performers at Risk of Leaving ───
-- Employees with top performance ratings who haven't received a bonus
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee_name,
    d.dept_name,
    e.job_title,
    ROUND(DATEDIFF(CURDATE(), e.hire_date) / 365, 1) AS tenure_years,
    pr.rating                                AS latest_rating,
    COALESCE(SUM(p.bonus), 0)               AS total_bonus_ytd
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN performance pr ON e.emp_id = pr.emp_id
    AND pr.review_year = YEAR(CURDATE())
LEFT JOIN payroll p ON e.emp_id = p.emp_id
    AND p.pay_period >= DATE_FORMAT(CURDATE(), '%Y-01-01')
WHERE e.status = 'Active'
  AND pr.rating >= 4
GROUP BY e.emp_id, employee_name, d.dept_name, e.job_title, tenure_years, pr.rating
HAVING total_bonus_ytd = 0
ORDER BY pr.rating DESC, tenure_years DESC;


-- ─── Q7: Overtime Cost Analysis – Top 10 Employees ───
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee_name,
    d.dept_name,
    e.job_title,
    SUM(p.overtime_pay)                      AS total_overtime_ytd,
    COUNT(DISTINCT p.pay_period)             AS pay_periods_with_overtime,
    ROUND(AVG(p.overtime_pay), 2)            AS avg_overtime_per_period
FROM payroll p
JOIN employees e ON p.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE p.pay_period >= DATE_FORMAT(CURDATE(), '%Y-01-01')
  AND p.overtime_pay > 0
GROUP BY e.emp_id, employee_name, d.dept_name, e.job_title
ORDER BY total_overtime_ytd DESC
LIMIT 10;


-- ─── Q8: Payroll Reconciliation – Tax Validation ───
-- Flag records where deductions don't add up correctly
SELECT
    payroll_id,
    emp_id,
    pay_period,
    gross_pay,
    tax_deducted,
    cpp_deducted,
    ei_deducted,
    net_pay,
    ROUND(gross_pay - tax_deducted - cpp_deducted - ei_deducted, 2)   AS calculated_net,
    ROUND(net_pay - (gross_pay - tax_deducted - cpp_deducted - ei_deducted), 2) AS discrepancy
FROM payroll
HAVING ABS(discrepancy) > 0.01    -- Flag any rounding errors > 1 cent
ORDER BY ABS(discrepancy) DESC;


-- ─── Q9: New Hire vs Attrition Balance ───
SELECT
    DATE_FORMAT(hire_date, '%Y-%m')         AS month,
    COUNT(*)                                AS new_hires,
    SUM(CASE WHEN DATE_FORMAT(termination_date, '%Y-%m') = DATE_FORMAT(hire_date, '%Y-%m')
             THEN 1 ELSE 0 END)             AS same_month_exits
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY month
ORDER BY month;


-- ─── Q10: Education Level vs Average Salary ───
SELECT
    e.education,
    COUNT(DISTINCT e.emp_id)        AS headcount,
    ROUND(AVG(p.gross_pay * 26), 2) AS avg_annual_salary,
    ROUND(MIN(p.gross_pay * 26), 2) AS min_salary,
    ROUND(MAX(p.gross_pay * 26), 2) AS max_salary
FROM employees e
JOIN payroll p ON e.emp_id = p.emp_id
WHERE e.status = 'Active'
  AND p.pay_period = (SELECT MAX(pay_period) FROM payroll)
GROUP BY e.education
ORDER BY avg_annual_salary DESC;
