-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
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

SELECT * FROM #temp_Sales

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

-- How many transaction do we have ?
SELECT COUNT([Order ID]) AS 'Number of records' FROM #temp_Sales

-- How many orders do we have ?
SELECT COUNT(DISTINCT [Order ID]) AS 'Number of orders' FROM #temp_Sales 

-- How much did we earn ? 
SELECT SUM([Price Each] * [Quantity Ordered]) AS 'Total sales' FROM #temp_Sales

-- Which products do we sell ?
SELECT DISTINCT([Product]) FROM #temp_Sales

-- How many of each product have we sold ?
SELECT [Product], SUM([Quantity Ordered]) AS 'Number of sales'
FROM #temp_Sales
GROUP BY [Product]
ORDER BY 2 DESC

-- What is the weight of each product in the total Sales ?
SELECT [Product]
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
, FORMAT((SUM([Price Each] * [Quantity Ordered]) / (
	SELECT SUM([Price Each] * [Quantity Ordered]) FROM #temp_sales
) * 100 ), 'N') AS '% Sales' 
FROM #temp_Sales
GROUP BY [Product]
ORDER BY 2 DESC

-- What is the average basket ?
SELECT FORMAT(AVG([Basket amount]), 'C') AS 'Average basket'
FROM (
	SELECT SUM([Price Each] * [Quantity Ordered]) AS 'Basket amount'
	FROM #temp_Sales
	GROUP BY [Order ID]
) AS t1

-- What is the average number of product by basket ?
SELECT SUM([Quantity Ordered]) / ( SELECT COUNT(distinct [Order ID])
									FROM #temp_Sales) AS 'Basket average quantity'
FROM  #temp_Sales

-- Where do we sell our products ?
SELECT [Purchase City]
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Number of products'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY [Purchase City]
ORDER BY 4 DESC

-- In which part of the day do we sell the most ?
SELECT [AMPM]
, COUNT(DISTINCT [Order ID]) AS 'Number of orders'
, SUM([Quantity Ordered]) AS 'Number of products'
, SUM([Price Each] * [Quantity Ordered]) AS 'Total sales'
FROM #temp_Sales
GROUP BY [AMPM]
ORDER BY 4 DESC

-- At what time do we sell the most ?

-- In which month do we sell the most ?

-- ======================
-- Data analysis
-- ======================

-- What was the best Year for sales? How much was earned that Year?

-- What was the best month for sales? How much was earned that month?

-- What City had the highest number of sales?

-- What time should we display adverstisement to maximize likelihood of customer’s buying product?

-- What products are most often sold together?

-- What product sold the most? Why do you think it sold the most?



