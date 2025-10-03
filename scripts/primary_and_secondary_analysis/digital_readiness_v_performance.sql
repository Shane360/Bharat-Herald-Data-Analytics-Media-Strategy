-- 6. Digital Readiness v Performance
-- Which cities show high digital readiness (based on smartphone, internet and 
-- literacy rates) but had low digital pilot engagement?

With digital_readiness AS (
	SELECT 
		cr.city_id,
		dc.city AS city_name,
		ROUND(AVG(cr.internet_penetration), 2) AS avg_internet_pen,
		ROUND(AVG(cr.literacy_rate), 2) AS avg_literacy,
		ROUND(AVG(cr.smartphone_penetration), 2) AS avg_smartphone_pen
	FROM fact_city_readiness cr
	LEFT JOIN dim_city dc
		ON cr.city_id = dc.city_id
	GROUP BY cr.city_id, dc.city
	ORDER BY avg_internet_pen DESC,
				avg_smartphone_pen DESC,
				avg_literacy DESC
),
digital_sales AS (
	SELECT 
		dp.city_id,
        (SUM(dp.downloads_or_accesses) * 1.0/ NULLIF(SUM(dp.users_reached), 0)) AS engagement_rate,
        SUM(ps.copies_sold + ps.copies_returned) AS population,
        SUM(dp.users_reached) AS total_users_reached,
        SUM(dp.downloads_or_accesses) AS total_engagement,
        ROUND(AVG(dp.avg_bounce_rate), 2) AS total_avg_bounce
    FROM fact_digital_pilot dp
	LEFT JOIN fact_print_sales ps
		ON dp.city_id = ps.city_id
    GROUP BY city_id
)
SELECT 
	dr.city_name,
    dr.avg_internet_pen AS internet_access,
    dr.avg_smartphone_pen AS smartphone_access,
    dr.avg_literacy AS literacy_rate,
    ds.total_users_reached,
    ds.population,
    ds.total_engagement AS user_engagements,
    ds.engagement_rate,
    ds.total_avg_bounce AS bounce_rate,
    RANK() OVER (ORDER BY dr.avg_internet_pen DESC) AS r_internet_access,
    RANK() OVER (ORDER BY dr.avg_smartphone_pen DESC) AS r_smartphone_access,
    RANK() OVER (ORDER BY dr.avg_literacy DESC) AS r_literacy,
    RANK() OVER (ORDER BY ds.population) AS r_population,
    RANK() OVER (ORDER BY ds.total_users_reached) AS r_reached,
    RANK() OVER (ORDER BY ds.engagement_rate DESC) AS r_engagement,
    RANK() OVER (ORDER BY ds.total_avg_bounce ASC) AS r_bounce
FROM digital_readiness dr
JOIN digital_sales ds
	ON dr.city_id = ds.city_id
ORDER BY 
	internet_access DESC,
    smartphone_access DESC,
    literacy_rate DESC,
    total_users_reached DESC,
    user_engagements DESC;


-- INSIGHTS
-- a. Kanpur's numbers suggest that the city had the most digital readiness having the highest rate of internet access and smartphone access
--    and having the top number of users reached but experienced the lowest user engagement and second highest bounce. 
--    The indicates inefficient engagement despite digital readiness.
-- b. Also, Varanasi recording the second highest internet and smartphone access reorded the lowest users reached 
--    (although they have a low population) and the worst bounce rate.
-- c. Ahmedabad recorded a strong engagement rating (3rd highest) despite having moderate readiness; indicating efficiency of marketing cost.
-- d. Delhi had the lowest internet access, smartphone access and the second lowest literacy rate. But surprisingly had a high
--    number of users reached (the 4th highest), the city recorded a decent user engagement (the 5th) but the lowest bounce rate (60.81%) 
--    This indicates the that the few users are highly engaged.
-- e. Jaipur had the least internet access but recorded decent smartphone use & literacy. 
-- f. The analysis shows a readiness- performance gap; cities like Kanpur and Varanasi have the infrastructure to support adoption but fail to 
--    engage, while Delhi and Lucknow convert limited readiness into strong adoption. 
--    Our strategy should strengthen the engagement in high-readiness cities and replicate success factors from Delhi and Lucknow in other cities. 

-- Recommendations:
-- a. Cities like Knapur and Varanasi with high readiness but low engagagement require interventions
-- b. We need to scale strategies in high-engagment, low-readiness markets like Delhi and Lucknow to
--    ensure both online and offline coverage.
-- c. Support low-literacy cities like Ranchi with simplified content
