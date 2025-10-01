
-- 4. Ad Revenue Trends by Category
-- How has ad revenue evolved across different ad categories between 2019 and 2024?
-- Which categories have remained strong, and which have declined?

-- Ad revenue by category
-- YoY change from 2019 - 2024
-- track increase/decline

SELECT * 
FROM fact_ad_revenue ar
LEFT JOIN dim_ad_category ac
	ON ar.ad_category = ac.ad_category_id;

-- Ad revenue by category
SELECT 
	ar.ad_category,
    ac.standard_ad_category as ad_category,
    CASE
		WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
        ELSE ar.quarter
	END AS year,
    SUM(ar.ad_revenue_inr) AS total_revenue
FROM fact_ad_revenue ar
LEFT JOIN dim_ad_category ac
	ON ar.ad_category = ac.ad_category_id
GROUP BY ar.ad_category, ac.standard_ad_category,     CASE
		WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
        ELSE ar.quarter
	END
ORDER BY total_revenue DESC, ar.ad_category;

-- Insights: Real Estate, Automobile and Government clients are the major drivers of revenue in the company with



-- Final query: YoY change in revenue from 2019 - 2024

With ad_revenue AS(
SELECT 
	ar.ad_category AS category_id,
    ac.standard_ad_category as ad_category,
    CASE
		WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
        ELSE ar.quarter
	END AS year,
    SUM(ar.ad_revenue_inr) AS total_revenue
FROM fact_ad_revenue ar
LEFT JOIN dim_ad_category ac
	ON ar.ad_category = ac.ad_category_id
WHERE RIGHT(ar.quarter, 4) BETWEEN 2019 AND 2024
GROUP BY ar.ad_category, ac.standard_ad_category, 
	    CASE
			WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
			ELSE ar.quarter
		END
),
yoy_changes AS (
	SELECT 
		category_id,
		ad_category,
		year,
		total_revenue,
		total_revenue - LAG(total_revenue) OVER (PARTITION BY category_id ORDER BY year) AS yoy_change,
		ROUND(
			(total_revenue - LAG(total_revenue) OVER (PARTITION BY category_id ORDER BY year))/
			NULLIF(LAG(total_revenue) OVER (PARTITION BY category_id ORDER BY year), 0) * 100
        , 2) AS pct_yoy_change
	FROM ad_revenue
)
SELECT
	category_id,
    ad_category,
    year,
    total_revenue,
    yoy_change,
    pct_yoy_change
FROM yoy_changes
ORDER BY total_revenue DESC, ad_category, year;


-- INSIGHTS
-- Government, Real Estate, and Automobile clients are the major drivers of revenue in the company with
-- a. Government responsible for the highest revenue in 2019 (131,377,322.07) 
--    but experienced a decline YoY between 2020 and 2023 (-16.5%, -3.04% and 5.2% respectively)
--    improvements were recorded in 2024 3.6%.
--    This indicates large income stream from Government which declined consistently prior to a minor correction in 2024
-- b. Real Estate Clients brought it the second highest revenues between 2021 - 2024 
--    (129 million in 2021, 111 million in 2022, 118 million in 2023, 114 million in 2024)
--    Massive growth in revenue from Real Estate companies but very volatile regardless as YoY change
--    oscillated from 28.7% in 2021 to -13.7% in 2022, then 6.3% in 2023 to -3.3% in 2024
--  c. Automobile clients pulled in the highest for the category in 2020 (92.9 million) with a decline in
--     2021 by -35.5% (62 million). Revenue trends were volatile as well with YoY change moving from 
--     and increase of 13.9% in 2022 to -0.7% in 2023, then pluning to -35.5% in 2024
--  d. By 2024, only Automobile companies and Government agencies recorded an increased, positive
--     revenue trend: 32.39% and 3.61 respectively.
--  e. FMCGs recorded most negative trend in YoY change with a -28.9% decline in revenue by 2024.
--  f. By total_revenue in 2024, Real Estate companies and Government Agencies still contribute the most
--     to the companies revenue (114 million and 108 million respectively)
