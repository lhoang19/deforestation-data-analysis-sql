select * from forest_area
select * from land_area
select * from regions

CREATE VIEW forestation AS
SELECT
fa.country_code AS CountryCode, 
fa.country_name AS CountryName, 
fa.year AS Year, 
fa.forest_area_sqkm AS ForestAreaSqKm, 
la.total_area_sq_mi AS TotalAreaSqMi, 
r.region AS Region, 
r.income_group As IncomeGroupd,
ROUND(((fa.forest_area_sqkm)/(la.total_area_sq_mi*2.59)*100),2) AS ForestAreaPercentage
FROM forest_area fa 
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code;

select * from forestation
---- Q1 ----- 
SELECT SUM(ForestAreaSqKm) AS ForestArea1990
FROM forestation
WHERE Year = '1990' AND CountryName = 'World'

SELECT SUM(ForestAreaSqKm) AS ForestArea2016
FROM forestation
WHERE Year = '2016' AND CountryName = 'World'

SELECT ((SELECT forest_area_sqkm FROM forest_area
WHERE year = 1990 AND country_name ='World')
-
(SELECT forest_area_sqkm FROM forest_area
WHERE year = 2016 AND country_name ='World')) AS forest_loss

SELECT ROUND((1- ((SELECT forest_area_sqkm FROM forest_area
WHERE year = 2016 AND country_name ='World')/(SELECT forest_area_sqkm FROM forest_area
WHERE year = 1990 AND country_name ='World')))*100,2) AS forest_loss

SELECT CountryCode, CountryName, TotalAreaSqMi
FROM forestation
WHERE 2.59*TotalAreaSqMi < (SELECT ((SELECT forest_area_sqkm FROM forest_area
WHERE year = 1990 AND country_name ='World')
-
(SELECT forest_area_sqkm FROM forest_area
WHERE year = 2016 AND country_name ='World')) AS forest_loss
) AND Year = 2016 ORDER BY TotalAreaSqMi DESC 

---- Q2----
SELECT CountryName, ForestAreaPercentage AS pct_forest_area_2016
FROM forestation WHERE Year = 2016 AND CountryName = 'World' 

SELECT Region, ROUND((SUM(ForestAreaSqKm)/SUM(TotalAreaSqMi*2.59))*100,2) AS pct_forest_area_2016
FROM forestation
WHERE Year = 2016
GROUP BY Region ORDER BY pct_forest_area_2016 DESC

SELECT CountryName, ForestAreaPercentage AS pct_forest_area_1990
FROM forestation WHERE Year = 1990 AND CountryName = 'World' 

SELECT Region, ROUND((SUM(ForestAreaSqKm)/SUM(TotalAreaSqMi*2.59))*100,2) AS pct_forest_area_1990
FROM forestation
WHERE Year = 1990
GROUP BY Region ORDER BY pct_forest_area_1990 DESC

SELECT region,
ROUND((region_forest_1990/region_area_1990)*100, 2)
AS [1990 Forest Percentage],
ROUND((region_forest_2016/region_area_2016)*100, 2)
AS [2016 Forest Percentage]
FROM (SELECT SUM(t0.ForestAreaSqKm) AS region_forest_1990,
      SUM (t0.TotalAreaSqMi*2.59) AS region_area_1990, t0.region,
      SUM (t1.ForestAreaSqKm) AS region_forest_2016,
      SUM (t1.TotalAreaSqMi*2.59) AS region_area_2016
FROM forestation t0, forestation t1
      WHERE t0.year ='1990'
      AND t1.year ='2016'
      AND t0.region = t1.region
GROUP BY t0.region) region_percent
ORDER BY [1990 Forest Percentage] DESC;

SELECT region, ROUND((region_forest_1990/region_area_1990)*100,2) AS [1990 Forest Percentage],
ROUND((region_forest_2016/region_area_2016)*100,2) AS [2016 Forest Percentage]
FROM(
SELECT SUM(t0.ForestAreaSqKm) AS region_forest_1990, 
SUM(t0.TotalAreaSqMi*2.59) AS region_area_1990, t0.region,
SUM(t1.ForestAreaSqKm) AS region_forest_2016, 
SUM(t1.TotalAreaSqMi*2.59) AS region_area_2016
FROM forestation t0, forestation t1
WHERE t0.year ='1990' AND t1.year='2016'
AND t0.region=t1.region GROUP BY t0.region) region_percent
ORDER BY [1990 Forest Percentage] DESC;

---Q3---
--- 3A. Success Stories ----
SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.Region,ROUND((f1.ForestAreaSqKm - f0.ForestAreaSqKm),2) AS [Change In Forest Area]
FROM forestation f1
JOIN forestation f0
ON (f1.year = '2016' AND f0.year = '1990')
AND f1.CountryCode = f0.CountryCode
WHERE f1.CountryCode != 'WLD' AND f1.ForestAreaSqKm !='0' AND f0.ForestAreaSqKm!='0'
ORDER BY [Change In Forest Area] DESC

SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.Region,ROUND(((1 - (f0.ForestAreaSqKm/f1.ForestAreaSqKm))*100),2) AS [PCT Change In Forest Area]
FROM forestation f1
JOIN forestation f0
ON (f1.year = '2016' AND f0.year = '1990')
AND f1.CountryCode = f0.CountryCode
WHERE f1.CountryCode != 'WLD' AND f1.ForestAreaSqKm !='0' AND f0.ForestAreaSqKm!='0'
ORDER BY [PCT Change In Forest Area] DESC

---- 3B Largest Concerns ----- 
SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.Region,ROUND((f1.ForestAreaSqKm - f0.ForestAreaSqKm),2) AS [Change In Forest Area]
FROM forestation f1
JOIN forestation f0
ON (f1.year = '2016' AND f0.year = '1990')
AND f1.CountryCode = f0.CountryCode
WHERE f1.CountryCode != 'WLD' AND f1.ForestAreaSqKm !='0' AND f0.ForestAreaSqKm!='0'
ORDER BY [Change In Forest Area] ASC

SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.Region,ROUND(((1 - (f0.ForestAreaSqKm/f1.ForestAreaSqKm))*100),2) AS [PCT Change In Forest Area]
FROM forestation f1
JOIN forestation f0
ON (f1.year = '2016' AND f0.year = '1990')
AND f1.CountryCode = f0.CountryCode
WHERE f1.CountryCode != 'WLD' AND f1.ForestAreaSqKm !='0' AND f0.ForestAreaSqKm!='0'
ORDER BY [PCT Change In Forest Area] ASC 

-----3C Quartiles------

WITH [3C_CTE_1] AS
(SELECT CountryName, year,ForestAreaSqKm, TotalAreaSqMi*2.59 AS total_area_sqkm, ForestAreaPercentage
FROM forestation
WHERE  year='2016' AND CountryName!='World'
        AND ForestAreaSqKm !=0 AND TotalAreaSqMi!=0),

[3C_CTE_2] AS
(SELECT [3C_CTE_1].CountryName, [3C_CTE_1].year, [3C_CTE_1].ForestAreaPercentage,
  --CASE WHEN [3C_CTE_1].ForestAreaPercentage > 75 THEN 4
  --WHEN [3C_CTE_1].ForestAreaPercentage <= 75 AND [3C_CTE_1].ForestAreaPercentage > 50 THEN 3
  --WHEN [3C_CTE_1].ForestAreaPercentage <= 50 AND [3C_CTE_1].ForestAreaPercentage > 25 THEN 2
  --ELSE 1
  CASE 
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 25 THEN 1
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 50 THEN 2
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 75 THEN 3
	  ELSE 4
  END AS quartile
  FROM [3C_CTE_1])

SELECT quartile, COUNT(quartile) AS [Number Country]
FROM [3C_CTE_2]
GROUP BY quartile
ORDER BY COUNT([3C_CTE_2].quartile) DESC;

SELECT CountryName, Region, ForestAreaPercentage
FROM forestation
WHERE Year = 2016 AND ForestAreaPercentage > 75
AND CountryCode != 'WLD' 
AND ForestAreaSqKm !=0
ORDER BY ForestAreaPercentage DESC 

----4.1-----
WITH CTE_1 AS (
SELECT
    CountryCode,
    CountryName,
    Year,
    ForestAreaSqKm,
    TotalAreaSqMi,
    Region,
    IncomeGroupd,
    ForestAreaPercentage,
    CASE
        WHEN ForestAreaPercentage >= 50 THEN 'High'
        WHEN ForestAreaPercentage >= 20 AND ForestAreaPercentage < 50 THEN 'Medium'
        ELSE 'Low'
    END AS Forestation_Level, RANK() OVER (PARTITION BY Region, Year ORDER BY ForestAreaPercentage DESC) AS Regional_Forestation_Rank
    FROM forestation
WHERE 
	CountryCode !='WLD'
	AND ForestAreaSqKm !=0 AND ForestAreaSqKm !=0
)

select Year, Forestation_Level, count(*) [Count Country] from CTE_1
where Year = 1990 or Year = 2016
group by Forestation_Level,Year order by Year

----4.2-----
WITH CTE_2 AS (
SELECT
    CountryCode,
    CountryName,
    Year,
    ForestAreaSqKm,
    TotalAreaSqMi,
    Region,
    IncomeGroupd,
    ForestAreaPercentage,
    CASE
        WHEN ForestAreaPercentage >= 50 THEN 'High'
        WHEN ForestAreaPercentage >= 20 AND ForestAreaPercentage < 50 THEN 'Medium'
        ELSE 'Low'
    END AS Forestation_Level,RANK() OVER (PARTITION BY IncomeGroupd, Region ORDER BY ForestAreaPercentage DESC) AS Regional_Forestation_Rank
    FROM forestation
WHERE 
	CountryCode !='WLD'
	AND ForestAreaSqKm !=0 AND ForestAreaSqKm !=0
)

SELECT CountryName, Year, Region, IncomeGroupd
FROM CTE_2 WHERE Regional_Forestation_Rank = 1 AND Year = 2016 
OR Regional_Forestation_Rank = 1 AND Year = 1990 ORDER BY Region, IncomeGroupd
