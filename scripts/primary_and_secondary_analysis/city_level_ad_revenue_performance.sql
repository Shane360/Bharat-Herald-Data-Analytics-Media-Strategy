-- 5. City-Level Ad Revenue Performance
-- Which cities generated the most ad revenue, and 
-- how does that correlate with their print circulation?

With totals AS (
	SELECT 
		dc.city,
		SUM(ps.net_circulation) AS total_circulation,
		SUM(ar.ad_revenue_inr) AS total_revenue
	FROM fact_print_sales ps 
	LEFT JOIN dim_city dc
		ON dc.city_id = ps.city_id
	LEFT JOIN fact_ad_revenue ar
		ON ar.edition_id = ps.edition_id
	GROUP BY dc.city
)
SELECT
	city,
    total_circulation,
    total_revenue,
    RANK() OVER (ORDER BY total_circulation DESC) as circulation_rank,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM totals
ORDER BY total_revenue DESC;


-- INSIGHTS
-- a. Patna city recorded the highest total revenue (17 Billion) while maintaining a total circulation of
--    ~ 1.13 Billion
-- b. The city with the lowest total revenue is Kanpur (14.6 Billion) with a total circulation of 
--    ~ 1.6 Billion.
-- c. Although Bhopal city recorded a higher circulation (~1.2 Billion) than Patna, they recorded a relatively lower 
--    total revenue - 16.9 Billion.
-- d. Mumbai and Jaipur also recorded much higher circulation (1.79 million and 2.09 million) than 
--    Patna and Bhopal but only pulled in a revenues around 16.4 Billion each. Marginal but notable.
-- e. Another notable city is Lucknow which recorded the lowest circulation (888 million copies) still pulled in
--    the 5th highest revenue of 16.1 Billion.
-- f. Kanpur with the lowest total revenue (14.6 Billion), but the 5th largest circulation also goes to show
--    that circulation does not necessarily correlate with the revenue generated. 
