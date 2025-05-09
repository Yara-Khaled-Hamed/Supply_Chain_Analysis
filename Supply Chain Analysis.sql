-- How does the average shipping duration vary by delivery status?
-- Helps identify delays by delivery type to improve fulfillment efficiency.

select [Delivery Status], AVG(supply_chain.[Days For Shipping (Real)]) as Average_Days
from Supply_Chain
group by [Delivery Status]

--------------

-- What is the most used method?
-- Found the most used method is DEBIT

select type , count([customer city]) Count_of_orders, round(SUM(sales),2) as Total_Sales
from Supply_Chain
group by Type
order by count_of_orders desc

-- Reveals preferred payment methods to optimize the checkout experience.

---------------

-- How do order volumes and delays vary by payment type and order status?
-- Identifies which payment types and statuses cause the most delays and orders.

SELECT 
    type, 
    [Order Status], 
    COUNT(*) AS Number_of_Orders, 
    SUM([Shipping Delay (Days)]) AS Total_Delays
FROM 
    Supply_Chain
GROUP BY 
    type, [Order Status]
ORDER BY 
    Number_of_Orders DESC;

--------------
-- Which 5 products have the highest order volumes?
-- Identifies high-demand products for inventory and promotion focus.

select top(5) [Product Name] , count(*) Number_of_Orders
from Supply_Chain
group by [Product Name]
order by Number_of_Orders desc

--------------------

-- Which shipping mode and segment face the most delays?
-- Pinpoints logistics bottlenecks in specific customer segments.

select [Shipping Mode],[Customer Segment], 
       avg([Shipping Delay (Days)]) Average_days, 
       min([Shipping Delay (Days)]) Min_Days , 
       max([Shipping Delay (Days)]) Max_days
from Supply_Chain
group by [Shipping Mode],[Customer Segment]
order by Average_days desc , [Shipping Mode]
-- Found the highest delay is Second Mode in Home Office segment and the first class

----------------------------

-- Which countries have over 70% late deliveries?
-- Highlights underperforming regions for delivery service improvements.

SELECT 
    [order Country], 
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN Late_Delivery_Risk = 'Late' THEN 1 ELSE 0 END) AS Late_Orders,
    ROUND(100.0 * SUM(CASE WHEN Late_Delivery_Risk = 'Late' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Late_Delivery_Percentage
FROM Supply_Chain
GROUP BY [order Country]
HAVING ROUND(100.0 * SUM(CASE WHEN Late_Delivery_Risk = 'Late' THEN 1 ELSE 0 END) / COUNT(*), 2) > 70
ORDER BY Late_Delivery_Percentage DESC;

----------------------------------------------------------------------

-- Which 5 products generate the most profit?
-- Focuses sales and marketing on top profit-generating products.

select top(5) [Product Name], avg([Order Item Profit Ratio]) as Total_Profit
from Supply_Chain
group by [Product Name]
order by Total_Profit desc

--------------------------------------------

-- How does profit change with different discount levels?
-- Less Discount means more profit
-- Optimizes discount policies to maximize profit per sale.

WITH DiscountBuckets AS (
    SELECT *,
        CASE 
            WHEN [Order Item Discount Rate] < 0.10 THEN '0-10%'
            WHEN [Order Item Discount Rate] between .10 and 0.20 THEN '10-20%'
            WHEN [Order Item Discount Rate]between .20 and 0.25 THEN '10-25%'
            ELSE '>25%' 
        END AS Discount_Range
    FROM Supply_Chain
)
SELECT 
    Discount_Range,
    COUNT(*) AS Order_Count,
    ROUND(AVG([Order Profit Per Order]), 2) AS Avg_Profit
FROM DiscountBuckets
GROUP BY Discount_Range
ORDER BY Avg_Profit desc;

---------------------

-- Which segment gives the most profit per discount unit?
-- Finds the most efficient segments for discount spending.

select [Customer Segment], 
       sum([Order Profit Per Order]) / sum([Order Item Discount]) 'Profit per 1 unit of discount'
from Supply_Chain
group by [Customer Segment]
order by 'Profit per 1 unit of discount' desc

------------------

-- Which cities drive the highest sales?
-- Identifies high-value cities for regional targeting and distribution.

select top(5) [Customer City], round(sum(Sales),2) Total
from Supply_Chain
group by [Customer City]
order by Total desc

-- Found there are some cities are best selling and there are not found in the order city
-- Highlights data inconsistencies or dropship scenarios in city-based analysis.

SELECT DISTINCT [order City]
FROM Supply_Chain
WHERE [order City] IN (
    select top(5) [Customer City]
    from Supply_Chain
    group by [Customer City]
    order by round(sum(Sales),2) desc
);

--------------------

-- Who are the top high-spending customers? 
-- Supports VIP customer retention strategies and loyalty programs.

select [Customer Full Name], round(sum(Sales),0) Sales
from Supply_Chain
group by [Customer Full Name]
order by Sales desc

-- Is "Mary Smith" one customer or multiple people?
-- Found "Mary Smith" is an outlier, possibly due to multiple identities across cities
-- Mary Smith from Caguas is the highest one
select [Customer Full Name], [Customer City], round(sum(Sales),0) Sales
from Supply_Chain
where [Customer Full Name] = 'Mary Smith'
group by [Customer Full Name], [Customer City]
order by Sales desc

-- Uncovers potential data quality issues and duplicate identities.

---------------

-- Which markets sell the most in quantity?
-- Aids in supply planning by identifying high-volume markets.

select Market, sum([Order Item Quantity]) Total_Quantity
from Supply_Chain
group by Market
order by Total_Quantity desc

-------------

-- Which products and categories lead in total sales?
-- Reveals top-selling products and categories for strategic focus.

SELECT [Product Name], [Category Name], 
       round([Product Price],2) Product_Price, 
       count(*)Total_Orders
FROM Supply_Chain
group by [Product Name], [Category Name], [Product Price]
order by Total_Orders desc

