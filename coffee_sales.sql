-- ============================================
-- DATABASE AND TABLE CREATION
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS coffee_sales;

-- Use the database
USE coffee_sales;

-- Create coffee table
CREATE TABLE IF NOT EXISTS coffee (
    order_date DATE,
    order_time TIME,
    hour_of_day INT,
    cash_type CHAR(10),
    card VARCHAR(50),
    money DECIMAL(10,2),
    coffee_name CHAR(30),
    Time_of_day CHAR(20),
    week_day CHAR(20),
    month_name CHAR(10),
    weekdaysort INT,
    monthsort INT
);

-- Load data from CSV
LOAD DATA INFILE 'd:/coffee_sales.csv'
INTO TABLE coffee
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================
-- 1. Top Customers by Spending (Last 6 Months)
-- ============================================

SELECT card AS customer_id, SUM(money) AS total_spending
FROM coffee 
WHERE order_date >= DATE_SUB((SELECT MAX(order_date) FROM coffee), INTERVAL 6 MONTH)
GROUP BY card
ORDER BY SUM(money) DESC
LIMIT 10;

-- ============================================
-- 2. Daily Sales Trend with 7-Day Moving Average
-- ============================================

WITH daily_sales AS (
    SELECT order_date, SUM(money) AS daily_revenue
    FROM coffee
    GROUP BY order_date
)
SELECT order_date,
       daily_revenue,
       ROUND(AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7d
FROM daily_sales
ORDER BY order_date;

-- ============================================
-- 3. Coffee Popularity by Time of Day
-- ============================================

WITH coffee_counts AS (
    SELECT coffee_name, time_of_day, COUNT(*) AS total_orders
    FROM coffee
    GROUP BY coffee_name, time_of_day
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY time_of_day ORDER BY total_orders DESC) AS rank_in_time
    FROM coffee_counts
)
SELECT *
FROM ranked
WHERE rank_in_time = 1;

-- ============================================
-- 4. Customer Purchase Frequency
-- ============================================

WITH customer_gaps AS (
    SELECT card AS customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY card ORDER BY order_date) AS prev_order_date
    FROM coffee
)
SELECT customer_id,
       ROUND(AVG(DATEDIFF(order_date, prev_order_date)), 2) AS avg_gap_days
FROM customer_gaps
WHERE prev_order_date IS NOT NULL
GROUP BY customer_id
ORDER BY avg_gap_days;

-- ============================================
-- 5. Payment Preference Trends (Cash vs Card)
-- ============================================

WITH monthly_usage AS (
    SELECT DATE_FORMAT(order_date,'%Y-%m') AS month_year,
           SUM(CASE WHEN cash_type='cash' THEN 1 ELSE 0 END) AS cash_orders,
           SUM(CASE WHEN cash_type='card' THEN 1 ELSE 0 END) AS card_orders,
           COUNT(*) AS total_orders
    FROM coffee
    WHERE order_date >= DATE_SUB((SELECT MAX(order_date) FROM coffee), INTERVAL 12 MONTH)
    GROUP BY month_year
)
SELECT month_year,
       cash_orders,
       card_orders,
       total_orders,
       ROUND((cash_orders*100)/total_orders, 2) AS cash_percentage,
       ROUND((card_orders*100)/total_orders, 2) AS card_percentage,
       ROUND(CASE WHEN cash_orders=0 THEN NULL ELSE ((cash_orders - LAG(cash_orders) OVER (ORDER BY month_year)) * 100.0) / LAG(cash_orders) OVER (ORDER BY month_year) END, 2) AS cash_pct_change,
       ROUND(CASE WHEN card_orders=0 THEN NULL ELSE ((card_orders - LAG(card_orders) OVER (ORDER BY month_year)) * 100.0) / LAG(card_orders) OVER (ORDER BY month_year) END, 2) AS card_pct_change
FROM monthly_usage
ORDER BY month_year;

-- ============================================
-- 6. Top-Selling Coffee by Day of Week
-- ============================================

SELECT week_day, coffee_name, sales_count
FROM (
    SELECT order_date, week_day, coffee_name, COUNT(*) AS sales_count,
           ROW_NUMBER() OVER (PARTITION BY week_day ORDER BY COUNT(*) DESC) AS rnk
    FROM coffee
    GROUP BY week_day, coffee_name
) t
WHERE rnk = 1
ORDER BY WEEKDAY(order_date);

-- ============================================
-- 7. Customer Segmentation by Spending
-- ============================================

SELECT CASE
           WHEN avg_money > 50 THEN 'High_spenders'
           WHEN avg_money BETWEEN 30 AND 50 THEN 'Medium_spenders'
           WHEN avg_money < 30 THEN 'Low_spenders'
       END AS spenders_category,
       COUNT(*) AS Total_customers
FROM (
    SELECT card AS customer_id, AVG(money) AS avg_money FROM coffee
    WHERE card IS NOT NULL
    GROUP BY card
    UNION ALL
    SELECT 'cash_customers' AS customer_id, AVG(money) AS avg_money FROM coffee
    WHERE cash_type='cash'
) t
GROUP BY spenders_category
ORDER BY CASE
           WHEN spenders_category='High_spenders' THEN 1
           WHEN spenders_category='Medium_spenders' THEN 2
           WHEN spenders_category='Low_spenders' THEN 3
         END;

-- ============================================
-- 8. High-Value Customers (RFM Analysis)
-- ============================================

WITH matrices AS (
    SELECT card AS customer_id,
           DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
           COUNT(*) AS frequency,
           SUM(money) AS monetary
    FROM coffee
    GROUP BY card
),
rfm AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,       -- lower recency = more recent = higher score
           NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
           NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM matrices
),
rfm_score AS (
    SELECT *, (recency_score + frequency_score + monetary_score) AS rfm_score
    FROM rfm
)
SELECT *
FROM (
    SELECT *, PERCENT_RANK() OVER (ORDER BY rfm_score DESC) AS pct_rnk
    FROM rfm_score
) t
WHERE pct_rnk <= 0.05;   -- top 5% customers




