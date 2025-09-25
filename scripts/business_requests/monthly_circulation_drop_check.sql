-- BUSINESS REQUESTS (BR)
-- BR1. Monthly Circulation Drop check
-- A report showing the top 3 months where any city recorded the sharpest MoM decline in net-circulation
WITH mom_net_circ AS (
	SELECT
		c.city as city_name,
		ps.month,
        ps.copies_sold,
        ps.copies_returned,
		ps.net_circulation,
		ps.net_circulation - LAG(ps.net_circulation) 
			OVER (PARTITION BY ps.city_id ORDER BY ps.month ASC) as mom_change
	FROM fact_print_sales ps
	LEFT JOIN dim_city c
		ON ps.city_id = c.city_id
	WHERE ps.month BETWEEN '2019-01' AND '2024-12'
)
SELECT 
	city_name,
    month,
    net_circulation
FROM mom_net_circ
WHERE mom_change IS NOT NULL
ORDER BY mom_change ASC
LIMIT 3;

/*
Insights: 
The company recorded the sharpest month-on-month decline in net circulation in 
January 2021 (Varansi city, with a drop of -59,807). Followed by November 2019 (in Varanasi city)
and January 2020 (in Jaipur city, with a decline of -51,858).
*/
