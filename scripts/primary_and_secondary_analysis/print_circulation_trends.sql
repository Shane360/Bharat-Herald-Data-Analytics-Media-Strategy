
-- ======================================================
-- PRIMARY & SECONDARY ANALYSIS
-- ======================================================
-- 1. Print Circulation Trends
-- What is the trend of copies printed, copies sold, and net circulation across all cities
-- from 2019 to 2024? How has this changed YoY?

SELECT * from fact_print_sales;

With yearly_circulation AS (
SELECT
	dc.city AS city_name,
    CAST(LEFT(ps.month, 4) AS UNSIGNED) AS year,
    SUM(ps.copies_sold + ps.copies_returned) AS copies_printed,
    SUM(copies_sold) AS total_copies_sold,
    SUM(ps.net_circulation) AS total_net_circulation
FROM fact_print_sales ps
LEFT JOIN dim_city dc ON ps.city_id = dc.city_id
WHERE CAST(LEFT(ps.month, 4) AS UNSIGNED) BETWEEN 2019 AND 2024
GROUP BY dc.city, CAST(LEFT(ps.month, 4) AS UNSIGNED)
),
yearly_change AS (
	SELECT 
		city_name,
		year,
		copies_printed,
		total_copies_sold,
		total_net_circulation,
		total_net_circulation - LAG(total_net_circulation) OVER (PARTITION BY city_name ORDER BY year) AS yoy_change
	FROM yearly_circulation
)
SELECT 
	city_name,
	year,
	copies_printed,
	total_copies_sold,
	total_net_circulation,
    yoy_change
FROM yearly_change
WHERE yoy_change IS NOT NULL
ORDER BY yoy_change, year, city_name;
