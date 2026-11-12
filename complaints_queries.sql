-- =====================================================================
-- Consumer Complaint Trends and Response Intelligence Platform
-- SQL analytical queries (KPIs 1 to 12)
-- Author: Stephanie Georgewill Alaye | Date: 12 November 2026
-- Source table: complaints_clean = Consumer_Complaints_Clean.csv loaded into
-- MySQL (or any SQL engine). Original data (Consumer_Complaints.xlsx) is unchanged.
-- Product_Short is the shortened product name used in the cleaned CSV.
-- All queries were run on the cleaned data (tested in SQLite); results match the dashboard. For MySQL, keep the backticks around column names with spaces or hyphens.
-- =====================================================================
-- Table: complaints_clean (import Consumer_Complaints_Clean.csv). MySQL/SQL Server-friendly; adjust date functions if needed.

-- 1 Total complaints
SELECT COUNT(*) AS total_complaints FROM complaints_clean;
-- 2 Annual volume + YoY (note: 2023 covers Jan-28 Aug only)
SELECT Year, COUNT(*) AS complaints,
  ROUND(100.0*(COUNT(*)-LAG(COUNT(*)) OVER (ORDER BY Year))/LAG(COUNT(*)) OVER (ORDER BY Year),1) AS yoy_pct
FROM complaints_clean GROUP BY Year ORDER BY Year;
-- 3 Monthly volume
SELECT Year_Month, COUNT(*) AS complaints FROM complaints_clean GROUP BY Year_Month ORDER BY Year_Month;
-- 4/7 Product volume and % share
SELECT Product_Short, COUNT(*) AS complaints,
  ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) AS pct_of_total
FROM complaints_clean GROUP BY Product_Short ORDER BY complaints DESC;
-- 5 Top issues
SELECT Issue, COUNT(*) AS complaints FROM complaints_clean GROUP BY Issue ORDER BY complaints DESC LIMIT 10;
-- 6 Sub-product / sub-issue
SELECT Product_Short, `Sub-product`, `Sub-issue`, COUNT(*) AS complaints
FROM complaints_clean GROUP BY Product_Short, `Sub-product`, `Sub-issue` ORDER BY complaints DESC;
-- 8 Company response distribution
SELECT `Company response to consumer`, COUNT(*) AS complaints,
  ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) AS pct FROM complaints_clean GROUP BY 1 ORDER BY 2 DESC;
-- 9 Timely % (valid Yes/No only) + excluded records
SELECT ROUND(100.0*SUM(`Timely response?`='Yes')/COUNT(*),2) AS timely_pct, COUNT(*) AS valid_records
FROM complaints_clean WHERE `Timely response?` IN ('Yes','No');
SELECT COUNT(*) AS excluded_records FROM complaints_clean WHERE `Timely response?` NOT IN ('Yes','No');
-- 10 In progress
SELECT COUNT(*) AS in_progress FROM complaints_clean WHERE `Company response to consumer`='In progress';
-- 11 Forwarding interval (average; median via Power BI/Python or PERCENTILE_CONT in SQL Server/Postgres)
SELECT ROUND(AVG(Forwarding_Interval_Days),2) AS avg_days, MAX(Forwarding_Interval_Days) AS max_days FROM complaints_clean;
SELECT Product_Short, ROUND(AVG(Forwarding_Interval_Days),2) AS avg_days, COUNT(*) AS n
FROM complaints_clean GROUP BY Product_Short ORDER BY avg_days DESC;

-- 11 (median) Median forwarding interval (works without PERCENTILE_CONT)
SELECT AVG(v) AS median_days FROM (
  SELECT Forwarding_Interval_Days AS v,
         ROW_NUMBER() OVER (ORDER BY Forwarding_Interval_Days) AS rn,
         COUNT(*) OVER () AS c
  FROM complaints_clean) t
WHERE rn IN (FLOOR((c + 1) / 2.0), FLOOR((c + 2) / 2.0));

-- Unusually long intervals (> P99 = 25 days)
SELECT `Complaint ID`, Product_Short, `Date submitted`, `Date received`, Forwarding_Interval_Days
FROM complaints_clean WHERE Long_Forwarding_Flag <> 'Normal' ORDER BY Forwarding_Interval_Days DESC;
-- Product x Issue
SELECT Product_Short, Issue, COUNT(*) AS complaints FROM complaints_clean GROUP BY 1,2 ORDER BY 3 DESC;
