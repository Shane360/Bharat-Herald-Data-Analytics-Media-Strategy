-- 3. Print Waste Analysis
-- Which cities have the largest gap between copies printed and net circulation?
-- How has this gap changed over time?

With yearly_metrics AS(
	SELECT 
		dc.city as city_name,
        CAST(LEFT(ps.month, 4) AS UNSIGNED) AS year,
        SUM(ps.copies_sold + ps.copies_returned) AS total_printed,
        SUM(ps.net_circulation) AS total_net_circulation
    FROM fact_print_sales ps
    LEFT JOIN dim_city dc
		ON ps.city_id = dc.city_id
	GROUP BY dc.city, CAST(LEFT(month, 4) AS UNSIGNED)
),
yearly_waste_gap AS (
	SELECT 
		city_name,
		year,
		total_printed,
		total_net_circulation,
		(total_printed - total_net_circulation) AS waste_gap,
		ROUND(
			CASE
				WHEN total_printed = 0 THEN NULL
                ELSE (total_printed - total_net_circulation) * 1.0/NULLIF(total_printed, 0)
			END, 2) AS waste_percentage
	FROM yearly_metrics
)
SELECT
	city_name,
    year,
    total_printed,
    total_net_circulation,
    waste_gap,
    waste_percentage,
    waste_gap - LAG(waste_gap) OVER (PARTITION BY city_name ORDER BY year ASC) AS yoy_change,
    RANK() OVER (PARTITION BY city_name ORDER BY waste_gap DESC) as yearly_rank
FROM yearly_waste_gap
ORDER BY city_name DESC, year;


-- INSIGHTS
-- a. Actual waste gap figures are concerning between 300,000 - 700,000 per city each year
--    This suggests a system or planning inefficiency
-- b. Shrinkage in Waste-gap can be seen over time e.g., 729,238 - 467,994 in Varansi, 318,360 - 217,382 in Ranchi 
--    indicating an adjustment to the require net circulation overtime which is an improvement.  
-- c. YoY changes are volatile as they swing from high negative values (-157,542) to positive values (18,076) and then back again.
-- 	  this signals either uneven operational improvements or demand fluctuations. 
-- d. Ratio decline puts in better perspective the changes as we can see a drop from 0.12 - 0.9
