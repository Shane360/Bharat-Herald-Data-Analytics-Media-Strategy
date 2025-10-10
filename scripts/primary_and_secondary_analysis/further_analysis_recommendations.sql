-- --------------------------------------------------------------
-- Further Analysis and Recommendations
-- --------------------------------------------------------------

-- 1. What should Bharat Herald’s phased digital transition strategy look like, given the 
--    readiness and engagement data? 

-- a. Phase 1: Address UI/UX issues such as long load times and small fonts on the Whatsapp platform.
-- b. Phase 2: Focus marketing efforts on the 3 priority cities (Mumbai, Varanasi, and Ahmedabad)
--    and push mobile ads to drive clicks.
-- c. Phase 3: Leverage adoption volume in cities like Lucknow and Patna and launch 
--    loyalty/subscription models; customer ads can be reach more targets in these cities through
--    print and the digital mediums.

SELECT DISTINCT
	platform,
	cumulative_feedback_from_customers
FROM fact_digital_pilot;

-- 2. How can Bharat Herald regain advertiser trust in key cities or categories where 
--    confidence dropped the most? 

With revenue_by_category AS (
	SELECT
		ar.ad_category,
		CASE
			WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
            ELSE ar.quarter
		END AS year,
		SUM(ad_revenue_inr) AS total_revenue
	FROM fact_ad_revenue ar
	LEFT JOIN dim_ad_category ac
		ON ar.ad_category = ac.standard_ad_category
	GROUP BY ar.ad_category, 		CASE
			WHEN ar.quarter LIKE '__-____' THEN RIGHT(ar.quarter, 4)
            ELSE ar.quarter
		END
)
SELECT 
	ac.standard_ad_category AS ad_category,
    rc.year,
	rc.total_revenue,
    LAG(rc.total_revenue) OVER (PARTITION BY ac.standard_ad_category ORDER BY rc.year) AS prev_year_revenue,
    rc.total_revenue - LAG(rc.total_revenue) OVER (PARTITION BY ac.standard_ad_category ORDER BY rc.year) AS yoy_change,
    ROUND(
    (1.0 * rc.total_revenue - LAG(rc.total_revenue) OVER (PARTITION BY ac.standard_ad_category ORDER BY rc.year))
    / NULLIF(LAG(rc.total_revenue) OVER (PARTITION BY ac.standard_ad_category ORDER BY rc.year), 0) * 100
    , 2) AS pct_yoy_change
FROM revenue_by_category rc
LEFT JOIN dim_ad_category ac
	ON rc.ad_category = ac.ad_category_id
ORDER BY ac.standard_ad_category ASC, rc.year;


-- a. Decline in circulation led to the reduced customer condifence and relaunching the 
--    digital platforms has the potential to attract more readership thereby driving more
--    potent ad campaigns.
-- b. Generally, digital adoption has surged and is more likely to be the sole source of news in 
--    the future, pivoting fully to digital platforms gives customers more reach as readership
--    can quickly attract even foreign engagement and patronage.
-- c. FMCGs recorded the most negative trend in YoY change with a -28.85% decline in revenue by 2024.
--    the company can upsell digital adoption as a more viable opportunity for FMCG customers to 
--     reach a larger audience. 
-- d. Consolidating on marketing efforts to convert more customers in the Automobile industry can potentially
--    boost revenue as this industry shows high growth potential.
-- e. Offer discounted ad bundles for customers in categories which experienced a decline or slow climb  
--    (FMCGs, Government and Real Estate).



-- 3. What changes to content format or delivery (e.g., WhatsApp bulletins, mobile
--    optimized e-papers) might boost digital engagement? 


-- a. Switch to Whatsapp format via a dedicated channel as the primary source.
--    57% of the comments indicated high interest in Whatsapp format.
-- b. Whatsapp can focus on headlines and quick 2 minute reports; this could reduce bounce rate
-- c. Mobile e-paper and app can feature more long-form content.
-- d. Tests can be run with these strategies to guage content length and bounce rate to fine tune.


-- 4. What role can subscription bundling, loyalty programs, or pay-per-article models 
--    play in revenue recovery? 

SELECT
	platform,
    COUNT(*)
FROM fact_digital_pilot
GROUP BY platform;

-- a. People are already used to free news and may not respond well to pay-walls or subscriptions
-- b. Mobile Ads on the Web, Mobile app and Whatsapp channels will get more eyes and are 
--    a more actionable strategy. 
-- c. A tiered approach can however be tested
--    * Free tier: Whatsapp headlines
--    * Premium tier: Indepth analyses and exclusive stories + ad-free or early access. 


-- 5. How can Bharat Herald leverage local influencers or journalists to re-establish 
--    digital credibility in regional markets?

-- a. Identify reporters in each city that have top engagement/readership and give them features.
-- b. Collaborate with influencers in these regions to drive readership.
