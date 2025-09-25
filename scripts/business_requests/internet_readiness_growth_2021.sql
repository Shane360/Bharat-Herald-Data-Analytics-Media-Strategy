
-- BR4. Internet Readiness  Print Efficiency Leaderboard (2021)
-- For each city, compute the change in internet penetration from Q1-2021 to  Q4-2021
-- Identify the city with the highest improvement

SELECT
	dc.city AS city_name,
	ROUND(AVG(CASE WHEN quarter = 'Q1-2021' THEN cr.internet_penetration END), 2) AS internet_rate_q1_2021,
	ROUND(AVG(CASE WHEN quarter = 'Q4-2021' THEN cr.internet_penetration END), 2) AS internet_rate_q4_2021,
	ROUND(
		AVG(CASE WHEN quarter = 'Q4-2021' THEN cr.internet_penetration END) -
		AVG(CASE WHEN quarter = 'Q1-2021' THEN cr.internet_penetration END)    
    , 2) AS delta_internet_rate
FROM fact_city_readiness cr
LEFT JOIN dim_city dc ON cr.city_id = dc.city_id
WHERE quarter LIKE '__-2021'
GROUP BY city
ORDER BY delta_internet_rate DESC
LIMIT 1;

-- Check Adoption of Digital Pilot
SELECT 
	dc.city AS city_name,
    SUM(dp.users_reached) AS total_users_reached,
    SUM(dp.downloads_or_accesses) AS total_dl_or_ac,
    SUM(dp.users_reached) + SUM(dp.downloads_or_accesses) as total_adoption,
    AS adoption_rate
    ROUND(AVG(dp.avg_bounce_rate), 2) AS total_avg_bounce
FROM fact_digital_pilot dp
LEFT JOIN dim_city dc
	ON dp.city_id = dc.city_id
GROUP BY dc.city
ORDER BY total_adoption DESC;

-- Check Lifetime Total Copies Printed by City

SELECT * 
FROM fact_print_sales;

SELECT 
	dc.city as city_name,
    (SUM(ps.copies_sold) + SUM(ps.copies_returned)) AS total_copies_printed
FROM fact_print_sales ps
LEFT JOIN dim_city dc
	ON ps.city_id = dc.city_id
GROUP BY dc.city
ORDER BY total_copies_printed DESC;

/*
INSIGHTS:
a. Kanpur recorded the highest growth in internet usage in 2021

b. Although this was the case in 2021, Kanpur recorded the lowest adoption
	(total users reached + total downloads or accesses) of the digital pilot.
*/
