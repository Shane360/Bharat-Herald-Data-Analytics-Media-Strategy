-- 8. Digital Relaunch City Prioritization
-- Based on digital readiness, pilot engagement, and print decline, which 3 cities should be
-- prioritized for Phase 1 of the digital relaunch?


With digital_readiness_index AS (
	SELECT 
		cr.city_id,
        dc.city,
        ROUND (
			(0.4 * (cr.smartphone_penetration/100.0)) +
            (0.3 * (cr.internet_penetration/100.0)) +
            (0.2 * (cr.literacy_rate/100.0)) +
            (0.1 * (1 - (dp.avg_bounce_rate/100.0)))
            , 3) AS dri
	FROM fact_city_readiness cr
		LEFT JOIN 
        (SELECT
			city_id,
            AVG(avg_bounce_rate) AS avg_bounce_rate
		FROM fact_digital_pilot
        GROUP BY city_id) dp
			ON cr.city_id = dp.city_id
		LEFT JOIN dim_city dc
			ON cr.city_id = dc.city_id
),
high_engagement AS (
	SELECT
        dri.city_id,
		dri.city,
        dri.dri,
        SUM(COALESCE(dp.downloads_or_accesses, 0)) AS total_engagement
    FROM fact_digital_pilot dp
    LEFT JOIN digital_readiness_index dri
		ON dp.city_id = dri.city_id
	GROUP BY dri.city_id, dri.city, dri.dri  
),
print_trends AS (
	SELECT
		ps.city_id,
        CAST(LEFT(ps.month, 4) AS UNSIGNED) AS year,
        SUM(COALESCE(ps.copies_sold, 0) + COALESCE(ps.copies_returned, 0)) as total_printed
    FROM fact_print_sales ps
    GROUP BY ps.city_id, CAST(LEFT(ps.month, 4) AS UNSIGNED)
),
print_decline AS (
	SELECT
        pt.city_id,
        pt.year,
        pt.total_printed,
        LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY pt.year) AS prev_year_printed,
        CASE
			WHEN LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY pt.year) IS NULL THEN NULL
            WHEN pt.total_printed < LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY pt.year)
            THEN 1 ELSE 0
		END AS is_declining,
       ROUND(
       CASE
			WHEN LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY year) IS NOT NULL
            THEN (pt.total_printed - LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY year))/
					LAG(pt.total_printed) OVER (PARTITION BY pt.city_id ORDER BY year)
			ELSE 0
		END, 3) AS decline_rate
	FROM print_trends pt
),
city_summary AS (
	SELECT
		he.city,
        he.dri,
        he.total_engagement,
        AVG(pd.decline_rate) AS avg_decline_rate
    FROM high_engagement he
    LEFT JOIN print_decline pd 
		ON he.city_id = pd.city_id
	GROUP BY he.city, he.dri, he.total_engagement
)
SELECT 
	city,
    dri AS digital_readiness_index,
    total_engagement,
    ROUND(avg_decline_rate, 3),
    ROUND(
		(0.5 * dri) +
        (0.3 * (total_engagement/ (SELECT MAX(total_engagement) FROM city_summary))) + 
        (0.2 * (ABS(avg_decline_rate)))
    , 3) AS priority_score -- based on high engagement and declining print_rate
FROM city_summary 
ORDER BY priority_score DESC
LIMIT 3;


-- METRICS
-- 1. Digital readiness index (DRI): a composite score of smartphone and internet penetration,
--    literacy and low bounce rate, shows how ready a city is
-- 2. Total_engagement: sum of app downloads and interactions, shows how much people are 
--    currently engaging.
-- 3. Avg_decline_rate: a negative value that shows falling print circulation, indicating
--    opportunity for digital uptake
-- 4. Priority_score: Weighted score (50% DRI + 30% engagement + 20% print decline), 
--    indicating candidates who are ready for digital relaunch

-- INSIGHTS
-- a. Mumbai wtih priority score of 0.618 is the most likely to be ready for a digital relaunch 
--    considering its total engagment (441,114). Even though the Digital Readiness Index is 
--    slightly lower than the others in this report, its strong engagement base compensates.
-- b. Varanasi is the second city in this priority list with a priority score of 0.586. 
-- 	  This city shows high potential and requires additional push to boost adoption.
-- c. Ahmedabad is close third (priority score of 0.58) with balanced DRI (0.692) and engagement.
--    decline rate is similar to the other cities and is suitable for Phase 2 of the digital lauch.
