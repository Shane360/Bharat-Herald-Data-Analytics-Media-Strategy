
-- BR5. Consistent Multi-Year Decline (2019 - 2024)
-- Find cities where both net_circulation and ad_revenue decreased every year from 2019
-- to 2024 (strictly decreasing sequences).

With edition_city AS(
	SELECT DISTINCT 
		edition_id, 
        city_id
    FROM fact_print_sales
),
yearly_circulation AS(
	SELECT
		city_id,
        CAST(LEFT(month, 4) AS UNSIGNED) AS year,
        SUM(net_circulation) AS yearly_net_circulation
    FROM fact_print_sales
    WHERE LEFT(month, 4) BETWEEN '2019' AND '2024'
    GROUP BY city_id, CAST(LEFT(month, 4) AS UNSIGNED)
),
yearly_ad_revenue AS(
	SELECT
		ec.city_id,
		CAST(RIGHT(quarter, 4) AS UNSIGNED) AS year,
		SUM(ar.ad_revenue_inr) AS yearly_ad_revenue
	FROM fact_ad_revenue ar
    JOIN edition_city ec 
		ON ec.edition_id = ar.edition_id
	WHERE ar.quarter LIKE '__-____'
		AND CAST(RIGHT(ar.quarter, 4) AS UNSIGNED) BETWEEN 2019 AND 2024
	GROUP BY ec.city_id, CAST(RIGHT(quarter, 4) AS UNSIGNED)
),
yearly_metrics AS(
SELECT
	dc.city_id,
    dc.city AS city_name,
    yc.year,
    yc.yearly_net_circulation,
    yr.yearly_ad_revenue
FROM yearly_circulation yc
JOIN yearly_ad_revenue yr
	ON yc.city_id = yr.city_id
	AND yc.year = yr.year
JOIN dim_city dc
	ON yc.city_id = dc.city_id
),
flagged_metrics AS(
	SELECT
		city_id,
		city_name,
		year,
		yearly_net_circulation,
		yearly_ad_revenue,
		CASE WHEN yearly_net_circulation < 
			LAG(yearly_net_circulation) OVER (PARTITION BY city_id ORDER BY year) 
			THEN 1 ELSE 0 END AS circulation_declined, -- indicates when there was a decline in circulation or not
		CASE WHEN yearly_ad_revenue < 
			LAG(yearly_ad_revenue) OVER (PARTITION BY city_id ORDER BY year) 
			THEN 1 ELSE 0 END AS ad_revenue_declined -- indicates when there was a decline in ad revenue or not
    FROM yearly_metrics
),
city_decline AS(
	SELECT
		city_id,
        city_name,
		CASE WHEN SUM(circulation_declined) = COUNT(*) - 1 
			THEN 'YES' ELSE 'NO' END AS is_declining_print, -- indicates when there was a decline or not
		CASE WHEN SUM(ad_revenue_declined) = COUNT(*) - 1 
			THEN 'YES' ELSE 'NO' END AS is_declining_ad_revenue,
		CASE WHEN SUM(circulation_declined) = COUNT(*) - 1 
			AND SUM(ad_revenue_declined) = COUNT(*) - 1
			THEN 'YES' ELSE 'NO' END AS is_declining_both
	FROM flagged_metrics
    GROUP BY city_id, city_name
    HAVING COUNT(DISTINCT year) = 6
)
SELECT 
    f.city_name,
    f.year,
    f.yearly_net_circulation,
    f.yearly_ad_revenue,
    c.is_declining_print,
    c.is_declining_ad_revenue,
    c.is_declining_both
FROM flagged_metrics f
JOIN city_decline c 
	ON f.city_id = c.city_id
WHERE is_declining_both = 'YES'
ORDER BY f.city_name, f.year;
