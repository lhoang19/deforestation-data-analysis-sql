# Deforestation Data Analysis by SQL
The project documented the detailed exploratory data analysis of deforestation from 1990 to 2016. The project consolidated my data cleaning, data querying, and data manipulation skills to reveal key deforestation insights and trends, using Microsoft SQL.

# Backgrounds
ForestQuery is on a mission to combat deforestation around the world and to raise awareness about this topic and its impact on the environment. The data analysis team at ForestQuery has obtained data from the World Bank that includes forest area and total land area by country and year from 1990 to 2016, as well as a table of countries and the regions to which they belong. The data analysis team has used SQL to bring these tables together and to query them in an effort to find areas of concern as well as areas that present an opportunity to learn from successes.

# Global Situation
First, I created the "Forestation" Table using SQL codes, as below

```
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
```

According to the World Bank, the total forest area of the world was 41,282,694.9 (km2) in 1990. As of 2016, the most recent year for which data was available, that number had fallen to 39,958,245.9 (km2), a loss of 1,324,449 (km2), or 3.21%. The forest area lost over this time period is slightly more than the entire land area of Peru listed for the year 2016 (which is 1,280,000 km2). 

```
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
```
# Regional Outlook
In 2016, the percent of the total land area of the world designated as forest was 31.38%. The region with the highest relative forestation was Latin American & Caribbean, with 46.16%, and the region with the lowest relative forestation was Middle East & North America, with 2.07% forestation.

In 1990, the percent of the total land area of the world designated as forest was 32.42%. The region with the highest relative forestation was Latin American & Caribbean, with 51.03%, and the region with the lowest relative forestation was Middle East & North America, with 1.77 % forestation.

Percent Forest Area by Region, 1990 & 2016
| Region | 1990 Forest Percentage | 2016 Forest Percentage |
| -------| -----------------------| -----------------------|
| Latin America & Caribbean | 51.03 | 46.16 | 
| Europe & Central Asia | 37.28 | 38.04 |
| North America | 35.65 | 36.04 | 
| World | 32.42 | 31.38 |
| Sub-Saharan Africa | 30.67 | 28.79 | 
| East Asia & Pacific | 25.78 | 26.36 |
| South Asia | 16.51 | 17.51 |
| Middle East & North Africa | 1.78 | 2.07 | 

The only regions of the world that decreased in percent forest area from 1990 to 2016 were Latin America & Caribbean (dropped from 51.03% to 46.16%) and _Sub-Saharan Africa (30.67 % to 28.79 %). All other regions actually increased in forest area over this time period. However, the drop in forest area in the two aforementioned regions was so large, the percent forest area of the world decreased over this time period from 32.42 % to 31.38%. 

```
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
```

# Country - Level Details
A. Success Stories

There is one particularly bright spot in the data at the country level, China. This country actually increased in forest area from 1990 to 2016 by 527,299.06 km2. It would be interesting to study what has changed in this country over this time to drive this figure in the data higher. The country with the next largest increase in forest area from 1990 to 2016 was the United States, but it only saw an increase of 79,200 km2, much lower than the figure for China. China and The United States are of course very large countries in total land area, so when we look at the largest percent change in forest area from 1990 to 2016, we aren’t surprised to find a much smaller country listed at the top. Iceland increased in forest area by 68.12% from 1990 to 2016. 

```
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

```

B. Largest Concerns

Which countries are seeing deforestation to the largest degree? We can answer this question in two ways. First, we can look at the absolute square kilometer decrease in forest area from 1990 to 2016. The following 3 countries had the largest decrease in forest area over the time period under consideration:

<img width="977" height="438" alt="image" src="https://github.com/user-attachments/assets/46c29cf9-80dd-4c7e-a3c3-ea916e581cc6" />
Forest Area Decrease by Country between 1990 and 2016

The second way to consider which countries are of concern is to analyze the data by percent decrease.

<img width="965" height="465" alt="image" src="https://github.com/user-attachments/assets/df2c37d4-684f-4918-95d7-8457a40f99a0" />

Top 5 Countries with Forest Area Percentage (%) Decrease from 1990 to 2016

When we consider countries that decreased in forest area percentage the most between 1990 and 2016, we find that four of the top 5 countries on the list are in the region of Sub – Saharan Africa. The countries are Togo, Nigeria, Uganda, and Mauritania. The 5th country on the list is Honduras which is in the Latin America & Caribbean region. 

From the above analysis, we see that Nigeria is the only country that ranks in the top 5 both in terms of absolute square kilometer decrease in forest as well as percent decrease in forest area from 1990 to 2016. Therefore, this country has a significant opportunity ahead to stop the decline and hopefully spearhead remedial efforts.

```
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
```

# Deforestation by Quartiles
I then divided the deforestation across the countries by four quartiles: (0-25%), (25% to 50%), (50% to 75%) and (75% to 100%). Based on the querying, I constructed the below pie chart showcasing the quartiles:

<img width="977" height="621" alt="image" src="https://github.com/user-attachments/assets/4e11e069-1d3b-48aa-a343-cc6f214117cf" />

Number of Countries with Forestation Rate

The largest number of countries in 2016 were found in the first quartile.

There were 9 countries in the 4th quartile in 2016. These are countries with a very high percentage of their land area designated as forest. The following is a list of these countries and their respective forest land, denoted as a percentage.

<img width="977" height="394" alt="image" src="https://github.com/user-attachments/assets/8ef83e3a-ac40-4aa8-a6f0-9afa85d66232" />

Percentage Designated as Forest (%) for countries in the 4th quartile

```
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
```

# Recommendations
Based on the World Bank Data, it was concluded that Latin America & Caribbean is the region with the highest performance from 1990 to 2016. Conversely, Middle East & North Africa was the lowest forestation area with the lowest percentage of forest area over total land area. 

Furthermore, there were only 9 countries with over 75% of forestation, whereas, 85 countries represented less than 25% of forestation rate over land area. This figure was concerning, particularly in areas such as Sub-Saharan Africa and Middle East & North Africa.









