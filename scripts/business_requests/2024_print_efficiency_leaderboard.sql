
-- BR3. 2024 Print Efficiency Leaderboard
-- Rank cities by print efficiency = net_circulation / copies_printed. 
-- Return top 5
With metrics_2024 AS (
	SELECT 
		city_id,
		SUM(copies_sold + copies_returned) AS copies_printed_2024,
		SUM(net_circulation) AS net_circulation_2024
	FROM fact_print_sales
	WHERE month LIKE '2024%'
    GROUP BY city_id
),
efficiency AS (
	SELECT
		city_id,
        copies_printed_2024,
        net_circulation_2024,
        CASE
			WHEN copies_printed_2024 > 0
				THEN (net_circulation_2024 / copies_printed_2024) 
            ELSE 0
		END AS efficiency_ratio
    FROM metrics_2024
)
SELECT
	dc.city as city_name,
    e.copies_printed_2024,
    e.net_circulation_2024,
    ROUND(e.efficiency_ratio, 3) AS efficiency_ratio,
    RANK() OVER (ORDER BY efficiency_ratio DESC) AS efficiency_rank_2024
FROM efficiency e
LEFT JOIN dim_city as dc
ON e.city_id = dc.city_id
ORDER by efficiency_ratio DESC
LIMIT 5;

/*
INSIGHTS:
a. Ranchi recorded the most efficient print ratio at 90.6% meaning ~10% of the papers in the city
	didnt get to the readers
b. of the top 5 Varansi recorded the least efficient ratio  which is also an impressive 89.8% 
	net circulation rate.
c. These figures represent high print efficiency as wastage is kept to a minimum
*/
