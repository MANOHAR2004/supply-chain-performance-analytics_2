USE supply_chain_db;

-- ══════════════════════════════════════════
-- Business Area 1 — Delivery Performance
-- ══════════════════════════════════════════

SELECT * from scms_shipments
limit 10;

-- 1) Business Question: Which shipment mode has the best 
-- on-time delivery rate?
-- Query 1 — On-Time Delivery Rate by Shipment Mode

SELECT shipment_mode,
count(*) as total_shipments,
sum(case 
when On_Time_Delivery = 'On Time' Then 1 
Else 0 
END) AS on_time_shipments,
sum(case 
when On_Time_Delivery = 'Late' Then 1 
Else 0 
END) AS Late_shipments,
round(sum(case 
when On_Time_Delivery = 'On Time' Then 1 
Else 0 
END) * 100.0/ count(*),2) AS ontime_rate
from scms_shipments
WHERE Shipment_Mode != 'Unknown'
group by shipment_mode
order by ontime_rate desc;


-- 2) Business question: Which vendors have the worst on-time delivery performance? Rank them.
-- Query 2 — Vendor Performance Ranking

WITH Vendor_summary as
( 
SELECT Vendor,
	count(*) as total_shipments,
	sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments
FROM scms_shipments
WHERE Shipment_Mode != 'Unknown'
group by Vendor
HAVING COUNT(*) > 20
)

SELECT
    Vendor,
    total_shipments,
    ROUND(
        total_shipments * 100.0 /
        SUM(total_shipments) OVER (),
        2
    ) AS total_shipment_percentage,
    Late_shipments,
    ROUND(Late_shipments * 100.0 / total_shipments, 2) AS Late_shipments_percentage,
DENSE_RANK() OVER (order by Late_shipments * 100.0/ total_shipments desc ) as Late_Vendor_ranking
FROM Vendor_summary
order by Late_shipments_percentage desc
LIMIT 15;



-- 3) Business question: Which countries experience the longest average delivery delays?
-- Query 3 — Average Delivery Delay by Country 

WITH country_summary as
( 
SELECT Country,
	count(*) as total_shipments,
    ROUND(avg(Delivery_Delay_Days),2) AS Average_delay_days,
    MAX(Delivery_Delay_Days) AS Maximum_delay_days,
	sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments,
        sum(case 
				WHEN Delivery_Delay_Days < 0 THEN 1
			ELSE 0
		END) AS Early_shipments
        
FROM scms_shipments
WHERE Shipment_Mode != 'Unknown'
group by Country
HAVING COUNT(*) > 50
)

SELECT
    Country,
total_shipments,
Average_delay_days,
Maximum_delay_days,
Early_shipments,
ROUND(Late_shipments * 100.0 / total_shipments, 2) AS Late_shipments_percentage,
ROUND(
        total_shipments * 100.0 /
        SUM(total_shipments) OVER (),
        2
) AS total_shipment_percentage
FROM country_summary
order by Average_delay_days desc
;


-- 4) Business question: Which shipment mode is most cost-efficient relative to shipment value?
-- Query 4 — Freight Cost Analysis by Shipment Mode

SELECT 
	Shipment_Mode,
	count(*) as total_shipments,
	ROUND(AVG(Freight_Cost_USD),2) AS Average_freight_cost,
	ROUND(AVG(Line_Item_Value),2) AS Average_line_item_value,
    ROUND(AVG(Freight_Cost_USD) * 100.0 / AVG(Line_Item_Value) ,2) AS Freight_Cost_percentage
FROM scms_shipments
WHERE Shipment_Mode != 'Unknown' AND Freight_Type = 'Separate' 

GROUP BY shipment_mode
ORDER BY Average_freight_cost DESC;


-- 5) Business Question: Which vendors are both expensive AND unreliable — high freight costs combined with high late delivery rates? And which vendors are our best performers on both dimensions?
-- Query 5 — Vendor Comprehensive Performance Scorecard
    

WITH Vendor_specification AS (
	SELECT Vendor,
	count(*) as total_shipments,
    ROUND(AVG(Freight_Cost_USD),2) AS Average_freight_cost,
    ROUND(AVG(Delivery_Delay_Days),2) AS Average_delay_days,
    ROUND(AVG(Line_Item_Value),2) AS Average_line_item_value,
    sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments
    FROM scms_shipments
    WHERE Shipment_Mode != 'Unknown' AND Freight_Type = 'Separate' 
    GROUP BY Vendor
    HAVING COUNT(*) > 20
    
),

Vendor_metrics AS (
	SELECT Vendor,
    total_shipments,
    Average_freight_cost,
    Average_delay_days,
    Average_line_item_value,
    Late_shipments,
    ROUND(Average_freight_cost * 100.0 / Average_line_item_value ,2) AS Freight_Cost_percentage,
    ROUND(Late_shipments * 100.0 / total_shipments, 2) AS Late_shipments_percentage
    FROM Vendor_specification
),

Vendor_ranking AS (
	SELECT *,
    NTILE (4) OVER ( ORDER BY Late_shipments_percentage DESC) AS Risk_assessment,
    DENSE_RANK() OVER (order by Late_shipments_percentage desc ) as Late_Vendor_ranking
    FROM Vendor_metrics
    
    
)

SELECT Vendor,
	total_shipments,
    Average_freight_cost,
    Freight_Cost_percentage,
    Late_shipments_percentage,
    Average_line_item_value,
    Average_delay_days,
    CASE 
		WHEN Risk_assessment = 1 THEN 'High Risk'
        WHEN Risk_assessment = 2 THEN 'Medium Risk'
        WHEN Risk_assessment = 3 THEN 'Low Risk'
        ELSE 'Reliable'
	END Vendor_performance_tier,
    Late_Vendor_ranking
    FROM Vendor_ranking
    ORDER BY Late_shipments_percentage DESC

;


-- 6) Business Question: Does vendor performance vary by country — are certain vendors reliable in some countries but consistently late in others? 
-- Query 6 — Vendor Performance by Country using PARTITION BY

SELECT * from scms_shipments
limit 10;

WITH Vendor_country_summary AS (
	SELECT Country,
    Vendor,
    count(*) as total_shipments,
    ROUND(AVG(Delivery_Delay_Days),2) AS Average_delay_days,
    sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments
    FROM scms_shipments
    WHERE Vendor != 'Unknown'
    AND Country != 'Unknown'
	group by Vendor, Country 
    HAVING COUNT(*) > 15
    

),

Vendor_Country_metrix AS (
	SELECT Country,
    Vendor,
    total_shipments,
    Late_shipments,
    Average_delay_days,
    ROUND(Late_shipments * 100.0 / total_shipments, 2) AS Late_shipments_percentage
    FROM Vendor_country_summary
),

Vendor_country_rank AS (
	SELECT *,
    DENSE_RANK() OVER (PARTITION BY Country ORDER BY Late_shipments_percentage desc ) AS Vendor_Country_rank
    FROM Vendor_Country_metrix
)

SELECT Country,
		Vendor,
		total_shipments,
		Average_delay_days,
		Late_shipments_percentage,
		Late_shipments,
		Vendor_country_rank
    FROM Vendor_country_rank
	WHERE vendor_country_rank = 1
    ORDER BY Late_shipments_percentage DESC;
    
    -- 7)Business question -Are our worst vendors getting better or worse over time?
    -- Query 7 — Vendor Performance Trend Over Time Using LAG
    
WITH Vendor_Year_Base AS (
    SELECT 
        Vendor,
        YEAR(Scheduled_Delivery_Date) AS Year,
        COUNT(*) AS total_shipments,
        sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments
    FROM scms_shipments
    WHERE Shipment_Mode != 'Unknown'
    GROUP BY Vendor, YEAR(Scheduled_Delivery_Date)
),

Vendor_Year_Metrics AS (
    SELECT 
        Vendor,
        Year,
        total_shipments,
        Late_shipments,
        ROUND(Late_shipments * 100.0 / total_shipments, 2) AS Late_percentage
    FROM Vendor_Year_Base
),

Vendor_Year_Trend AS (
    SELECT 
        Vendor,
        Year,
        total_shipments,
        Late_percentage,
        LAG(Late_percentage, 1) OVER (
            PARTITION BY Vendor
            ORDER BY Year
        ) AS Prev_Year_Late_percentage,
        ROUND(
            Late_percentage -LAG(Late_percentage, 1) OVER (
            PARTITION BY Vendor
            ORDER BY Year
        ), 2) AS YoY_change
    FROM Vendor_Year_Metrics
)

SELECT 
    Vendor,
    Year,
    total_shipments,
    Late_percentage,
    Prev_Year_Late_percentage,
    YoY_change
FROM Vendor_Year_Trend
WHERE Vendor IN (
    SELECT Vendor FROM Vendor_Year_Base 
    GROUP BY Vendor
    HAVING SUM(total_shipments) > 200
)
ORDER BY Vendor, Year;


-- 8)Business Question : Which vendors consistently deliver later than the overall average delay across all vendors? I want to identify chronic underperformers, not just one-time failures.
-- Query 8 — Correlated Subquery

SELECT Vendor,
	COUNT(*) AS total_shipments,
    
    ROUND(AVG(Delivery_Delay_Days),2) AS Vendor_avg_delay_days,
     ( SELECT round(avg(Delivery_Delay_Days),2) FROM scms_shipments) as overall_avg_delays,
    sum(case 
			when On_Time_Delivery = 'Late' Then 1 
			Else 0 
		END) AS Late_shipments,
    ROUND(
        SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Late_shipments_percentage,
	ROUND(AVG(Delivery_Delay_Days) - ( select AVG(Delivery_Delay_Days)  FROM scms_shipments),2) AS diff_between_overall_avg_vendor_avg
    FROM scms_shipments
    GROUP BY Vendor
    HAVING COUNT(*) > 50  and AVG(Delivery_Delay_Days) > (
    SELECT AVG(Delivery_Delay_Days) FROM scms_shipments)
    
    ORDER BY Vendor_avg_delay_days desc;
    
-- 9)Business Question: Which product groups have the worst delivery performance and highest freight cost burden?
-- Query 9 — Product Group Performance

SELECT Product_Group,
	COUNT(*) as total_shipments,
    ROUND(AVG(Delivery_Delay_Days),2) as avg_delay_day,
    ROUND(AVG(Freight_Cost_USD),2) as avg_freight_cost,
    ROUND(AVG(Line_Item_Value),2) as avg_line_item_value,
    
    sum(case 
			when On_Time_Delivery = 'On Time' Then 1 
			Else 0 
		END) AS On_time_delivery,
	ROUND(sum(case 
			when On_Time_Delivery = 'On Time' Then 1 
			Else 0 
		END) * 100.0/ COUNT(*),2) AS On_time_delivery_rate,
    ROUND(SUM(Freight_Cost_USD) * 100.0/ SUM(Line_Item_Value),2) AS  freight_cost_percentage
    
	FROM scms_shipments
    WHERE Shipment_Mode <> 'Unknown'
  AND Freight_Type = 'Separate'
GROUP BY Product_Group
ORDER BY On_time_delivery_rate asc;
    
-- 10)Business Question: Which countries present the highest combined supply chain risk? I need a single score combining delivery delay, late shipment rate, and freight cost burden so I can prioritise where to focus intervention
-- Query 10 — Country Risk Scorecard


WITH delivery_metrics AS (
    SELECT Country,
        COUNT(*) AS total_shipments,
        ROUND(AVG(Delivery_Delay_Days), 2) AS avg_delay_day,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS Late_shipments_percentage
    FROM scms_shipments
    WHERE Shipment_Mode != 'Unknown'
    GROUP BY Country
    HAVING COUNT(*) > 50
),
cost_metrics AS (
    SELECT Country,
        ROUND(AVG(Freight_Cost_USD), 2) AS avg_freight_cost,
        ROUND(
            SUM(Freight_Cost_USD) * 100.0 / SUM(Line_Item_Value), 2
        ) AS freight_cost_percentage
    FROM scms_shipments
    WHERE Freight_Type = 'Separate'
    AND Shipment_Mode != 'Unknown'
    GROUP BY Country
),
composite_risk AS (
    SELECT 
        d.Country,
        d.total_shipments,
        d.avg_delay_day,
        d.Late_shipments_percentage,
        c.avg_freight_cost,
        c.freight_cost_percentage,
        ROUND(
            (d.Late_shipments_percentage * 0.5) + 
            (d.avg_delay_day * 0.3) + 
            (COALESCE(c.freight_cost_percentage, 0) * 0.2)
        , 2) AS composite_risk_score
    FROM delivery_metrics d
    LEFT JOIN cost_metrics c ON d.Country = c.Country
)
SELECT 
    Country,
    total_shipments,
    avg_delay_day,
    avg_freight_cost,
    Late_shipments_percentage,
    freight_cost_percentage,
    composite_risk_score,
    RANK() OVER (ORDER BY composite_risk_score DESC) AS Risk_Rank
FROM composite_risk
ORDER BY Risk_Rank;


-- 11)Business Question: Which countries receive the most procurement value and how has that changed year over year?
-- Query 11 — Country Procurement Value and Year Over Year Change

WITH Country_Year_Base AS (
    SELECT 
        Country,
        YEAR(Scheduled_Delivery_Date) AS year,
        COUNT(*) AS total_shipments,
        ROUND(SUM(Line_Item_Value), 2) AS total_line_item_value
    FROM scms_shipments
    WHERE Country IN (
        SELECT Country FROM scms_shipments
        GROUP BY Country
        HAVING COUNT(*) >= 100
    )
    GROUP BY Country, YEAR(Scheduled_Delivery_Date)
),
Country_Year_Trend AS (
    SELECT *,
        LAG(total_line_item_value, 1) OVER (
            PARTITION BY Country ORDER BY year
        ) AS prev_year_value,
        ROUND(
            total_line_item_value - LAG(total_line_item_value, 1) OVER (
                PARTITION BY Country ORDER BY year
            )
        , 2) AS absolute_yoy_change,
        ROUND(
            (total_line_item_value - LAG(total_line_item_value, 1) OVER (
                PARTITION BY Country ORDER BY year)
            ) * 100.0 / NULLIF(
                LAG(total_line_item_value, 1) OVER (
                    PARTITION BY Country ORDER BY year), 0)
        , 2) AS yoy_percentage_change
    FROM Country_Year_Base
)
SELECT 
    Country,
    year,
    total_shipments,
    total_line_item_value,
    prev_year_value,
    absolute_yoy_change,
    yoy_percentage_change
FROM Country_Year_Trend
ORDER BY Country, year;


-- 12) Business Question: How has shipment volume changed month over month and what is the cumulative procurement value over time?
-- Query 12 — Monthly Shipment Volume and Running Total
    
WITH monthly_base AS (
	SELECT MONTH(Scheduled_Delivery_Date) AS month,
    YEAR(Scheduled_Delivery_Date) AS year,
    COUNT(*) AS total_shipments,
    SUM(Line_Item_Value) as total_line_item_value
    FROM scms_shipments
    WHERE Scheduled_Delivery_Date IS NOT NULL
    GROUP BY YEAR(Scheduled_Delivery_Date),MONTH(Scheduled_Delivery_Date) 
    
	
),

monthly_trend AS (
	SELECT year,
		month,
        total_shipments,
        total_line_item_value,
        LAG(total_shipments,1) OVER( ORDER BY year, month ) AS previous_month_shipment,
		ROUND(total_shipments - LAG(total_shipments,1) OVER( ORDER BY year, month),2) AS absolute_mom_change,
        ( total_shipments - LAG(total_shipments) OVER (ORDER BY year, month))* 100.0 / NULLIF(LAG(total_shipments,1) OVER( ORDER BY year, month ),0) AS mom_percentage_change,
        ROUND(SUM(total_line_item_value) OVER( ORDER BY year, month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ),2) AS running_total_value 
        
	FROM monthly_base 
)

SELECT year,
	month,
    total_shipments,
    total_line_item_value,
    previous_month_shipment,
    absolute_mom_change,
    mom_percentage_change,
    running_total_value 
    
FROM monthly_trend
ORDER BY YEAR,MONTH ;
    


-- 13) Business Question: Is overall delivery performance improving or deteriorating quarter by quarter? I need to see the quarterly on-time rate with a comparison to the previous quarter so I can identify whether interventions are working.
-- Query 13 — Quarterly On-Time Rate Trend
    
    
WITH quarterly_base AS (
	SELECT year(Scheduled_Delivery_Date) AS year,
    quarter(Scheduled_Delivery_Date) AS quarter,
    COUNT(*) AS total_shipments,
    sum(case 
			when On_Time_Delivery = 'On Time' Then 1 
			Else 0 
		END) AS On_time_shipments,
	ROUND(sum(case 
			when On_Time_Delivery = 'On Time' Then 1 
			Else 0 
		END) * 100.0/ COUNT(*),2) AS on_time_shipment_rate
    FROM scms_shipments
    WHERE Scheduled_Delivery_Date IS NOT NULL
    GROUP BY YEAR(Scheduled_Delivery_Date),quarter(Scheduled_Delivery_Date)
    
	
),

quarterly_trend AS (
	SELECT year,
		quarter,
        total_shipments,
        On_time_shipments,
        on_time_shipment_rate,
        LAG(on_time_shipment_rate, 1) OVER (ORDER BY year, quarter) AS previous_quarter_rate,
ROUND(
    on_time_shipment_rate - LAG(on_time_shipment_rate, 1) OVER (ORDER BY year, quarter)
, 2) AS qoq_rate_change
	FROM quarterly_base 
)

SELECT year,
		quarter,
        total_shipments,
        On_time_shipments,
        on_time_shipment_rate,
        previous_quarter_rate,
        qoq_rate_change
    
FROM quarterly_trend 
ORDER BY year,quarter ;
    
-- 14)Business Question: How has the annual late shipment rate changed year over year across the entire programme?    
-- Query 14 — Year Over Year Late Rate Change
    
   
    
WITH annual_base AS (
	SELECT year(Scheduled_Delivery_Date) AS year,
    COUNT(*) AS total_shipments,
        SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) as late_shipments,
		ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS Late_shipment_rate
    FROM scms_shipments
    GROUP BY YEAR(Scheduled_Delivery_Date)
    
	
),

annual_metric AS (
	SELECT year,
        total_shipments,
        late_shipments,
        Late_shipment_rate,
        LAG(late_shipment_rate, 1) OVER (ORDER BY year ) AS previous_annual_rate,
		ROUND(late_shipment_rate - LAG(late_shipment_rate, 1) OVER (ORDER BY year ),2) AS yoy_change_pp,
        case
			when late_shipment_rate - LAG(late_shipment_rate, 1) OVER (ORDER BY year ) < -1 THEN  "Improving"
            when late_shipment_rate - LAG(late_shipment_rate, 1) OVER (ORDER BY year ) > 1 THEN  "Deteriorating"
            WHEN late_shipment_rate - LAG(late_shipment_rate, 1) OVER (ORDER BY year) BETWEEN -1 AND 1 THEN "Stable"
            else "No prior data"
        END as performance_status
        from annual_base
)

SELECT year,
		late_shipments,
        total_shipments,
        Late_shipment_rate,
        previous_annual_rate,
        yoy_change_pp,
        performance_status
FROM  annual_metric
ORDER BY year ;


-- 15) Business Question: Can we segment all vendors into four performance tiers — High Risk, Medium Risk, Low Risk, and Reliable — based on a combined score of late rate and average delay?
-- Query 15 — NTILE Vendor Segmentation


WITH Vendor_metrics AS (
    SELECT 
        Vendor,
        COUNT(*) AS total_shipments,
        ROUND(AVG(Delivery_Delay_Days), 2) AS avg_delay_days,
        SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) AS late_shipments,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS late_shipment_percentage
    FROM scms_shipments
    GROUP BY Vendor
    HAVING COUNT(*) > 30
),
Vendor_segmented AS (
    SELECT 
        Vendor,
        total_shipments,
        avg_delay_days,
        late_shipment_percentage,
        NTILE(4) OVER (
            ORDER BY late_shipment_percentage DESC
        ) AS risk_bucket
    FROM Vendor_metrics
)
SELECT 
    Vendor,
    total_shipments,
    avg_delay_days,
    late_shipment_percentage,
    risk_bucket,
    CASE 
        WHEN risk_bucket = 1 THEN 'High Risk'
        WHEN risk_bucket = 2 THEN 'Medium Risk'
        WHEN risk_bucket = 3 THEN 'Low Risk'
        WHEN risk_bucket = 4 THEN 'Reliable'
    END AS Performance_Tier
FROM Vendor_segmented
ORDER BY late_shipment_percentage DESC;


-- 16) Business Question: How do shipments break down across the classification hierarchy — from Product Group down to Sub Classification? I need to see the hierarchy levels and shipment counts at each level.
-- Query 16 — Recursive CTE for Shipment Classification Hierarchy


WITH RECURSIVE classification_hierarchy AS (
    SELECT 
        1 AS level,
        Product_Group AS category,
        'All Products' AS parent_category,
        COUNT(*) AS total_shipments
    FROM scms_shipments
    GROUP BY Product_Group
    
    UNION ALL
    
    SELECT 
        2 AS level,
        s.Sub_Classification AS category,
        s.Product_Group AS parent_category,
        COUNT(*) AS total_shipments
    FROM scms_shipments s
    GROUP BY s.Product_Group, s.Sub_Classification
)
SELECT 
    level,
    category,
    parent_category,
    total_shipments,
    ROUND(
        total_shipments * 100.0 / 
        SUM(total_shipments) OVER (PARTITION BY level)
    , 2) AS pct_of_level
FROM classification_hierarchy
ORDER BY level, total_shipments DESC;

-- 17) Business Question: Can we create a reusable report that generates complete performance metrics for any vendor on demand?
-- Query 17 — Stored Procedure for Vendor Report

DELIMITER //

CREATE PROCEDURE GetVendorReport(IN vendor_name VARCHAR(200))
BEGIN

    -- Query 1: Overall vendor scorecard
    SELECT 
        vendor_name AS Vendor,
        COUNT(*) AS total_shipments,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'On Time' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS on_time_rate,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS late_rate,
        ROUND(AVG(Delivery_Delay_Days), 2) AS avg_delay_days,
        SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) AS late_shipments,
        ROUND(AVG(Freight_Cost_USD), 2) AS avg_freight_cost,
        COUNT(DISTINCT Country) AS countries_served
    FROM scms_shipments
    WHERE Vendor = vendor_name;

    -- Query 2: Freight type distribution
    SELECT 
        Freight_Type,
        COUNT(*) AS shipments,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS late_rate
    FROM scms_shipments
    WHERE Vendor = vendor_name
    GROUP BY Freight_Type;

    -- Query 3: Year by year performance trend
    SELECT 
        YEAR(Scheduled_Delivery_Date) AS year,
        COUNT(*) AS total_shipments,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS late_rate,
        ROUND(AVG(Delivery_Delay_Days), 2) AS avg_delay_days
    FROM scms_shipments
    WHERE Vendor = vendor_name
    GROUP BY YEAR(Scheduled_Delivery_Date)
    ORDER BY year;

    -- Query 4: Country breakdown for this vendor
    SELECT 
        Country,
        COUNT(*) AS shipments,
        ROUND(
            SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) 
            * 100.0 / COUNT(*), 2
        ) AS late_rate,
        ROUND(AVG(Delivery_Delay_Days), 2) AS avg_delay_days
    FROM scms_shipments
    WHERE Vendor = vendor_name
    GROUP BY Country
    ORDER BY shipments DESC;

END //

DELIMITER ;




call GetVendorReport('SCMS from RDC');
CALL GetVendorReport('CIPLA LIMITED');
