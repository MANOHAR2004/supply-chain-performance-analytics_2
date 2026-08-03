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


-- Business Question: Which vendors consistently deliver later than the overall average delay across all vendors? I want to identify chronic underperformers, not just one-time failures.
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
    
-- Business Question: Which product groups have the worst delivery performance and highest freight cost burden?
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
    
-- Business Question: Which countries present the highest combined supply chain risk? I need a single score combining delivery delay, late shipment rate, and freight cost burden so I can prioritise where to focus intervention
-- Query 10 — Country Risk Scorecard


WITH raw_metrix as (
	SELECT Country,
    count(*) as total_shipments,
    ROUND(AVG(Delivery_Delay_Days),2) as avg_delay_day,
        ROUND(
        SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Late_shipments_percentage,
	ROUND(AVG(Freight_Cost_USD),2) as avg_freight_cost,
    ROUND(SUM(Freight_Cost_USD) * 100.0/ SUM(Line_Item_Value),2) AS  freight_cost_percentage

FROM scms_shipments
WHERE Freight_Type = 'Separate'
AND Shipment_Mode != 'Unknown'
group by Country
HAVING total_shipments > 50

),

composit_risk_rank as ( 
	SELECT *, 
    round((Late_shipments_percentage * 0.5) + (avg_delay_day * 0.3) + (freight_cost_percentage * 0.2),2) as composite_risk_score
FROM raw_metrix) 

  
Select Country,
	total_shipments,
    avg_delay_day,
    avg_freight_cost,
    Late_shipments_percentage,
    freight_cost_percentage,
    composite_risk_score,
    RANK() OVER( ORDER BY composite_risk_score DESC ) AS Risk_Rank
    
from composit_risk_rank
;



