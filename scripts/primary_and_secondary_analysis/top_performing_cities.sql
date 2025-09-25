
-- 2. Top Performing Cities
-- Which cities contributed the highest to net circulation and copies sold in 2024?
-- Are these cities still profitable to operate in?

SELECT * FROM fact_print_sales;


With sales_2024 AS (
	SELECT
		dc.city_id,
        dc.city AS city_name,
        SUM(ps.net_circulation) AS total_net_circulation,
        SUM(ps.copies_sold) AS total_copies_sold
    FROM fact_print_sales ps
    LEFT JOIN dim_city dc
		ON ps.city_id = dc.city_id
	WHERE CAST(LEFT(ps.month, 4) AS UNSIGNED) = 2024
    GROUP BY dc.city_id, dc.city
),
revenue_2024 AS (
	SELECT
		dc.city_id,
        dc.city AS city_name,
        SUM(ar.ad_revenue_inr) AS total_revenue
	FROM fact_ad_revenue ar
	LEFT JOIN fact_print_sales ps
		ON ar.edition_id = ps.edition_id
	LEFT JOIN dim_city dc
		ON ps.city_id = dc.city_id
	WHERE CAST(LEFT(ps.month, 4) AS UNSIGNED) = 2024
	GROUP BY ar.edition_id, dc.city_id, dc.city 
)

SELECT 
	s.city_id,
    s.city_name,
    s.total_net_circulation AS city_total_net_circulation,
    s.total_copies_sold AS city_total_copies_sold,
    r.total_revenue,
    (r.total_revenue/NULLIF(s.total_net_circulation, 0)) AS revenue_per_copy,
    (s.total_net_circulation/SUM(s.total_net_circulation) OVER ()) * 100 AS pct_net_circulation,
	SUM(s.total_net_circulation) OVER () AS grand_total_net_circulation,   
    SUM(S.total_copies_sold) OVER () AS grand_total_copies_sold
FROM sales_2024 s
LEFT JOIN revenue_2024 r
	ON s.city_id = r.city_id
GROUP BY s.city_id, s.city_name, s.total_net_circulation, s.total_copies_sold, r.total_revenue
ORDER BY pct_net_circulation DESC, total_revenue DESC, revenue_per_copy DESC
;


-- INSIGHTS
-- a. Jaipur contributed the most to the net circulation (13.94%), 
--    it also contributed the most to revenue (INR2.74 Billion) for 2024
-- b. Varanasi follows closely, contributing 13.93% to the net circulation
--    recording INR2.45 billion in total revenue for 2024
-- c. Note though, Lucknow, although contributing the least to net circulation (5.95%)
--    Lucknow city contributes the highest revenue per copy sold (INR1,524)
-- d. Patna city contributes the second highest in profitability per copies sold (INR1,261.68)
--    and a % net circulation of 7.6%
