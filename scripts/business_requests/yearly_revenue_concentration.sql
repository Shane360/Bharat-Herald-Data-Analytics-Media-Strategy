
-- BR2. Yearly Revenue Concentration by Category
-- Identify ad categories that contributed > 50% of total yearly ad revenue for each year


WITH total_ad_revenue AS (
	SELECT
		ad_category,
        CASE 
			WHEN quarter LIKE '__-____' THEN RIGHT(quarter, 4)
            ELSE quarter
		END as year,
        SUM(ad_revenue_inr) AS total_revenue_inr
	FROM fact_ad_revenue
    GROUP BY 		
		ad_category,
        CASE 
			WHEN quarter LIKE '__-____' THEN RIGHT(quarter, 4)
            ELSE quarter
		END
),
yearly_ad_revenue AS (
	SELECT 
		ad_category,
        year,
        total_revenue_inr,
		SUM(total_revenue_inr) OVER (PARTITION BY year) AS total_revenue_year,
        (total_revenue_inr / SUM(total_revenue_inr) OVER (PARTITION BY year)) * 100 AS pct_of_year_total
    FROM total_ad_revenue
    GROUP BY ad_category, year, total_revenue_inr
)
SELECT
    yr.year,
    ac.standard_ad_category AS category_name,
    yr.total_revenue_inr AS category_revenue,
    yr.total_revenue_year,
    yr.pct_of_year_total
FROM yearly_ad_revenue yr
LEFT JOIN dim_ad_category ac
	ON yr.ad_category = ac.ad_category_id
WHERE ROUND(pct_of_year_total, 2) > 35
ORDER BY yr.year,  yr.pct_of_year_total; 


/*
Insights: 
- No ad category contributed to more than 50% of total yearly ad revenue.
- Neither did any category contribute to > 40% of total yearly revenue
- However, the Government contributed to about 35.69% of total yearly revenue in 2019.
- This means that revenue is well diversified across the categories.
*/

