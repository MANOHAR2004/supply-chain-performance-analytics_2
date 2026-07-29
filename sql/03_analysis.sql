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
    


