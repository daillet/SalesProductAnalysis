-- =============================================
-- Author:		Thomas DAILLE
-- Create date: 29/12/2022
-- Description:	Sql analysis of a sales dataset
-- =============================================
-- Columns
-- [Order ID]
-- [Product]
-- [Quantity Ordered]
-- [Price Each]
-- [Order Date]
-- [Purchase Address]

-- ======================
-- Data cleaning and data processing
-- ======================

SELECT * from [dbo].[Sales] 

DROP TABLE IF EXISTS #temp_Sales

CREATE TABLE #temp_Sales (
	[Order ID] int
	, [Product] nvarchar(50)
	, [Quantity Ordered] numeric(9,2)
	, [Price Each] numeric(9,2)
	, [Order Date] date
	, [Order Time] time
	, [AMPM] char(2)
	, [Purchase Street] nvarchar(50)
	, [Purchase City] nvarchar(50)
	, [Purchase Postal Code] char(8)
)

INSERT INTO #temp_Sales
SELECT [Order ID]
	, [Product]
	, [Quantity Ordered]
	, [Price Each]
	, CAST(CONCAT(SUBSTRING(SUBSTRING([Order Date], 0, CHARINDEX(' ', [Order Date])),4,3), LEFT(SUBSTRING([Order Date], 0, CHARINDEX(' ', [Order Date])), 2), SUBSTRING(SUBSTRING([Order Date], 0, CHARINDEX(' ', [Order Date])), 6,10)) AS Date)
	, RIGHT([Order Date], 5)
	, CASE WHEN LEFT(RIGHT([Order Date], 5), 2) < 12 THEN 'AM' ELSE 'PM' END
	, SUBSTRING(TRIM('"' FROM [Purchase Address]), 0, CHARINDEX(',', TRIM('"' FROM [Purchase Address])))
	, SUBSTRING([Purchase Address], CHARINDEX(',', [Purchase Address])+2, (CHARINDEX(',', TRIM('"' FROM [Purchase Address]), CHARINDEX(',', [Purchase Address])+2) - (CHARINDEX(',', [Purchase Address])+1)))
	, SUBSTRING(TRIM('"' FROM [Purchase Address]), CHARINDEX(',', [Purchase Address], CHARINDEX(',', [Purchase Address])+2)+2, 10)
FROM [dbo].[Sales]

SELECT * FROM #temp_Sales

-- ======================
-- Data discovery
-- ======================

-- =============
-- How many transaction do we have ?
SELECT COUNT([Order ID]) AS 'Number of records' FROM #temp_Sales
-- => We count 185 686 transactions.

-- =============
-- How many orders do we have ?
SELECT COUNT(DISTINCT [Order ID]) AS 'Number of orders' FROM #temp_Sales 
-- => We count 178 437 different orders.

-- =============
-- How much did we earn ? 
SELECT SUM([Price Each] * [Quantity Ordered]) AS 'Total sales' FROM #temp_Sales
-- => We sold for $ 34 465 537,94.

-- =============
-- Which products do we sell ?
SELECT DISTINCT([Product]) FROM #temp_Sales
-- => We sell 19 different products.

-- =============
-- How many of each product have we sold ?
SELECT [Product], SUM([Quantity Ordered]) AS 'Number of sales'
FROM #temp_Sales
GROUP BY [Product]
ORDER BY 2 DESC
-- => The product we sell the most is AAA Batteries

-- =============
-- What is the weight of each product in the total Sales ?
SELECT [Product]
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
, FORMAT((SUM([Price Each] * [Quantity Ordered]) / (
	SELECT SUM([Price Each] * [Quantity Ordered]) FROM #temp_sales
) * 100 ), 'N') AS '% Sales' 
FROM #temp_Sales
GROUP BY [Product]
ORDER BY 2 DESC
-- => Macbook Pro Laptop is our best seller with 23,31% of the total sales.

-- =============
-- What is the average basket ?
SELECT FORMAT(AVG([Basket amount]), 'C') AS 'Average basket'
FROM (
	SELECT SUM([Price Each] * [Quantity Ordered]) AS 'Basket amount'
	FROM #temp_Sales
	GROUP BY [Order ID]
) AS t1
-- => The average amont per basket is $ 193,15.

-- =============
-- What is the average number of product by basket ?
SELECT SUM([Quantity Ordered]) / ( SELECT COUNT(distinct [Order ID])
									FROM #temp_Sales) AS 'Basket average quantity'
FROM  #temp_Sales
-- => The average number of product per basket is 1,17.

-- =============
-- Where do we sell our products ?
SELECT [Purchase City]
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Number of products'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY [Purchase City]
ORDER BY 4 DESC
-- => We sell principally in San Francisco

-- =============
-- In which part of the day do we sell the most ?
SELECT [AMPM]
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Number of products'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY [AMPM]
ORDER BY 4 DESC
-- => It's in the afternoon that we sell the most.

-- =============
-- In which part of the afternoon do we sell the most ? 7s
SELECT
CASE 
	WHEN LEFT([Order Time], 2) < 16  THEN 'Between 12h00 and 16h00'
	WHEN LEFT([Order Time], 2) < 20  THEN 'Between 16h00 and 20h00'
	ELSE 'After 20h'
END AS 'Time period'
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Number of products'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
WHERE [AMPM] = 'PM'
GROUP BY CASE 
	WHEN LEFT([Order Time], 2) < 16  THEN 'Between 12h00 and 16h00'
	WHEN LEFT([Order Time], 2) < 20  THEN 'Between 16h00 and 20h00'
	ELSE 'After 20h'
END
ORDER BY 4 DESC
-- We sell the most between 4pm and 8pm.

-- =============
-- At what time do we sell the most ?
SELECT LEFT([Order Time], 2) AS 'Hours'
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Sum of quantity ordered'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY LEFT([Order Time], 2) 
ORDER BY 4 DESC
-- => We have a record number of orders at 7pm.

-- =============
-- In which month do we sell the most ?
SELECT MONTH([Order Date]) AS 'Month of year'
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Sum of quantity ordered'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY MONTH([Order Date]) 
ORDER BY 4 DESC
-- => The month of the year when we sell the most is December.

-- =============
-- In which week do we sell the most ?
SELECT DATEPART(week, [Order Date]) AS 'Month of year'
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Sum of quantity ordered'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY DATEPART(week, [Order Date]) 
ORDER BY 4 DESC
-- => The week of the year when we sell the most is the week 51, i.e Christmas week.

-- ======================
-- Data analysis
-- ======================

-- =============
-- What products are most often sold together?
SELECT [Product A], [Product B], COUNT([Pairs]) AS 'Number of Pairs'
FROM (
	SELECT t1.[Order ID]
	, t1.[Product] AS 'Product A'
	, t2.[Product] AS 'Product B'
	, t1.[Product] + ', ' + t2.[Product] AS 'Pairs'
	FROM #temp_Sales t1
	JOIN #temp_Sales t2 ON t1.[Order ID] = t2.[Order ID]
	WHERE  t1.[Product] !=  t2.[Product]
) AS t3
GROUP BY [Product A], [Product B]
ORDER BY 3 DESC
-- => The products most often sold together are the Lightning Charging cable and the iPhone.

-- =============
-- What product sold the most? Why do you think it sold the most?
SELECT [Product], sum([Quantity Ordered]) AS "Sum of Quantity Ordered", [Price Each]
FROM #temp_Sales
GROUP BY [Product], [Price Each]
ORDER BY 2 DESC
-- => The products we sell the most are the cheapest.
