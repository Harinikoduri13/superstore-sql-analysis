-- ====================================================
-- SUPERSTORE SALES & PROFITABILITY ANALYSIS PROJECT
-- ====================================================


-- ====================================================
-- 1. BASIC KPI ANALYSIS
-- ====================================================

-- Total Sales
SELECT ROUND(SUM(Sales),2) AS total_sales
FROM superstore;

-- Total Profit
SELECT ROUND(SUM(Profit),2) AS total_profit
FROM superstore;

-- Total Orders
SELECT COUNT(DISTINCT `Order ID`)
AS total_orders
FROM superstore;

-- Total Customers
SELECT COUNT(DISTINCT `Customer ID`)
AS total_customers
FROM superstore;



-- ====================================================
-- 2. SALES ANALYSIS
-- ====================================================

-- Sales by Region
SELECT Region,
ROUND(SUM(Sales),2) AS total_sales
FROM superstore
GROUP BY Region
ORDER BY total_sales DESC;


-- Sales by Category
SELECT Category,
ROUND(SUM(Sales),2)
AS total_sales
FROM superstore
GROUP BY Category
ORDER BY total_sales DESC;


-- Sales by Sub-Category
SELECT `Sub-Category`,
ROUND(SUM(Sales),2)
AS total_sales
FROM superstore
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;


-- Monthly Sales Trend
SELECT MONTH(
STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
) AS month_num,

ROUND(SUM(Sales),2)
AS total_sales

FROM superstore

WHERE STR_TO_DATE(`Order Date`,
'%m/%d/%Y') IS NOT NULL

GROUP BY month_num
ORDER BY month_num;


-- Year-wise Sales Trend
SELECT YEAR(
STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
) AS order_year,

ROUND(SUM(Sales),2)
AS total_sales

FROM superstore

WHERE STR_TO_DATE(`Order Date`,
'%m/%d/%Y') IS NOT NULL

GROUP BY order_year
ORDER BY order_year;



-- ====================================================
-- 3. PROFIT ANALYSIS
-- ====================================================

-- Profit by Category
SELECT Category,
ROUND(SUM(Profit),2)
AS total_profit
FROM superstore
GROUP BY Category
ORDER BY total_profit DESC;


-- Profit by Sub-Category
SELECT `Sub-Category`,
ROUND(SUM(Profit),2)
AS total_profit
FROM superstore
GROUP BY `Sub-Category`
ORDER BY total_profit DESC;


-- Region-wise Profit
SELECT Region,
ROUND(SUM(Profit),2)
AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC;


-- Profit Margin by Category
SELECT Category,

ROUND(SUM(Sales),2)
AS total_sales,

ROUND(SUM(Profit),2)
AS total_profit,

ROUND(
(SUM(Profit)/SUM(Sales))*100,
2
) AS profit_margin_percent

FROM superstore

GROUP BY Category
ORDER BY profit_margin_percent DESC;


-- Loss Making Products
SELECT `Product Name`,
ROUND(SUM(Sales),2) AS total_sales,
ROUND(SUM(Profit),2) AS total_profit
FROM superstore
GROUP BY `Product Name`
HAVING total_profit < 0
ORDER BY total_profit ASC
LIMIT 10;



-- ====================================================
-- 4. PRODUCT ANALYSIS
-- ====================================================

-- Top 10 Products by Sales
SELECT `Product Name`,

ROUND(SUM(Sales),2)
AS total_sales

FROM superstore

GROUP BY `Product Name`
ORDER BY total_sales DESC
LIMIT 10;


-- Top 5 Loss-making Products
SELECT `Product Name`,

ROUND(SUM(Profit),2)
AS total_profit

FROM superstore

GROUP BY `Product Name`

HAVING total_profit < 0

ORDER BY total_profit
LIMIT 5;


-- Category + Sub-category Analysis
SELECT Category,
`Sub-Category`,

ROUND(SUM(Sales),2)
AS total_sales,

ROUND(SUM(Profit),2)
AS total_profit

FROM superstore

GROUP BY Category,
`Sub-Category`

ORDER BY total_profit DESC;



-- ====================================================
-- 5. CUSTOMER ANALYSIS
-- ====================================================

-- Top 5 Customers by Sales
SELECT `Customer Name`,

ROUND(SUM(Sales),2)
AS total_sales

FROM superstore

GROUP BY `Customer Name`
ORDER BY total_sales DESC
LIMIT 5;


-- Top 10 Customers by profit
SELECT `Customer Name`,
ROUND(SUM(Profit),2)
AS total_profit
FROM superstore
GROUP BY `Customer Name`
ORDER BY total_profit DESC
LIMIT 10;



-- ====================================================
-- 6. SHIPPING ANALYSIS
-- ====================================================

-- Average Shipping Days
SELECT AVG(
DATEDIFF(
STR_TO_DATE(`Ship Date`,
'%m/%d/%Y'),

STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
)
) AS avg_shipping_days

FROM superstore;



-- ====================================================
-- 7. WINDOW FUNCTIONS
-- ====================================================

-- Top 3 Products in Each Category
SELECT *

FROM
(
SELECT Category,

`Product Name`,

ROUND(SUM(Profit),2)
AS total_profit,

ROW_NUMBER() OVER
(
PARTITION BY Category
ORDER BY SUM(Profit) DESC
) AS rn

FROM superstore

GROUP BY Category,
`Product Name`

) x

WHERE rn <= 3;



-- ====================================================
-- 8. YEAR OVER YEAR (YoY) GROWTH
-- ====================================================

WITH yearly_sales AS
(
SELECT YEAR(
STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
) AS order_year,

ROUND(SUM(Sales),2)
AS total_sales

FROM superstore

WHERE STR_TO_DATE(`Order Date`,
'%m/%d/%Y') IS NOT NULL

GROUP BY order_year
)

SELECT *,

LAG(total_sales)
OVER(
ORDER BY order_year
) AS previous_year_sales,

ROUND(
(
(total_sales -
LAG(total_sales)
OVER(
ORDER BY order_year
))
/
LAG(total_sales)
OVER(
ORDER BY order_year
)
)*100,
2
) AS yoy_growth_percent

FROM yearly_sales;



-- ====================================================
-- 9. RUNNING TOTAL (CUMULATIVE SALES)
-- ====================================================

SELECT

YEAR(
STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
) AS order_year,

ROUND(SUM(Sales),2)
AS yearly_sales,

ROUND(
SUM(SUM(Sales))
OVER(
ORDER BY YEAR(
STR_TO_DATE(`Order Date`,
'%m/%d/%Y')
)
),2
) AS cumulative_sales

FROM superstore

WHERE STR_TO_DATE(`Order Date`,
'%m/%d/%Y') IS NOT NULL

GROUP BY order_year
ORDER BY order_year;