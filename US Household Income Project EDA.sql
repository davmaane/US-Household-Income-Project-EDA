-- US Household Income Project

-- Exploratory Data Analysis

SELECT * 
FROM us_household_income_project.ushouseholdincome;

SELECT * 
FROM us_household_income_project.ushouseholdincome_statistics;

-- identifying the Largest states by Land

SELECT 
	State_Name,
    SUM(ALand) as total_land_area, 
    SUM(AWater) as total_water_area
FROM us_household_income_project.ushouseholdincome
GROUP BY State_Name
ORDER BY total_land_area DESC
;

-- Adding a limit to see Top 10

SELECT 
	State_Name,
    SUM(ALand) as total_land_area, 
    SUM(AWater) as total_water_area
FROM us_household_income_project.ushouseholdincome
GROUP BY State_Name
ORDER BY total_land_area DESC
LIMIT 10;
-- Texas, California and Missouri seem to have the largest total area of land


-- identifying the Largest states by Water by Ordering from highest to lowest on the AWater

SELECT 
	State_Name,
    SUM(ALand) as total_land_area, 
    SUM(AWater) as total_water_area
FROM us_household_income_project.ushouseholdincome
GROUP BY State_Name
ORDER BY total_water_area DESC
LIMIT 10;
-- Michigan, Texas and Florida seem to have the largest area of water  


-- Tying both Tables together

SELECT * 
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id;
-- it seems like we are missing some data on the mean, median and mode


-- Filtering out empty records  

SELECT * 
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
;

--  identifying the Top States with the average Lowest Income 


SELECT 
	hi.State_Name, 
    AVG(Mean) as average_mean, 
    AVG(Median) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name;

-- rounding off values

SELECT 
	hi.State_Name, 
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name
ORDER BY  average_mean
;


-- using a limit to select top 5 with the lowest average income by state

SELECT 
	hi.State_Name, 
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name
ORDER BY  average_mean
LIMIT 5;
-- Puerto Rico, Mississippi, Arkansas, West Virginia and Alabama are the top 5 with the lowest average income  

-- identifying the Top States with the average Highest Income by Ordering by average_mean from highest to lowest

SELECT 
	hi.State_Name, 
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name
ORDER BY  average_mean DESC
LIMIT 10;
-- District of Columbia, Connecticut and New Jersey are significantly the top states with the highest average income

-- Ranking Top States with average Highest and Lowest Income 
WITH state_income AS (
    SELECT 
        hi.State_Name,
        ROUND(AVG(hs.Mean), 1) AS avg_mean_income,
        ROUND(AVG(hs.Median), 1) AS avg_median_income,
        RANK() OVER (ORDER BY AVG(hs.Mean) DESC) AS high_rank,
        RANK() OVER (ORDER BY AVG(hs.Mean) ASC) AS low_rank
    FROM us_household_income_project.ushouseholdincome hi
    INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
        ON hi.id = hs.id
    WHERE hs.Mean <> 0
    GROUP BY hi.State_Name
)
SELECT 
    CASE WHEN high_rank <= 5 THEN 'Top 5 Highest' ELSE 'Bottom 5 Lowest' END AS category,
    State_Name,
    avg_mean_income,
    avg_median_income
FROM state_income
WHERE high_rank <= 5 OR low_rank <= 5
ORDER BY avg_mean_income DESC;

-- identifying the Highest average household income Cities by States

SELECT 
	hi.State_Name, 
    City,
    round(avg(mean),1) as average_mean
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name, City
ORDER BY average_mean DESC
LIMIT 10;
-- Delta Junction, Short Hills and Narberth are the top Cities with the highest average income


-- identifying the Top Cities by States with the Lowest average Income by Ordering average_mean from lowest to highest
SELECT 
	hi.State_Name, 
    City,
    round(avg(mean),1) as average_mean
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY hi.State_Name, City
ORDER BY average_mean ASC
LIMIT 10;
-- Center (Colorado), Estancia and Corsica are the top Cities with the lowest average income

-- Ranking Top Cities by States with average Highest and Lowest Income 

WITH city AS (
    SELECT 
         hi.State_Name,
         hi.city,
        ROUND(AVG(hs.Mean), 1) AS avg_mean_income,
        ROUND(AVG(hs.Median), 1) AS avg_median_income,
        RANK() OVER (ORDER BY AVG(hs.Mean) DESC) AS high_rank,
        RANK() OVER (ORDER BY AVG(hs.Mean) ASC) AS low_rank
    FROM us_household_income_project.ushouseholdincome hi
    INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
        ON hi.id = hs.id
    WHERE hs.Mean <> 0
    GROUP BY  hi.State_Name, hi.city
)
SELECT 
    CASE WHEN high_rank <= 5 THEN 'Top 5 Highest' ELSE 'Bottom 5 Lowest' END AS category,
     State_Name,
     city,
    avg_mean_income,
    avg_median_income
FROM city
WHERE high_rank <= 5 OR low_rank <= 5
ORDER BY avg_mean_income DESC;


-- identifying average Highest Income by Type

SELECT 
	type, 
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY  average_mean DESC
LIMIT 20;

-- Doing a count on the type

SELECT 
	Type, 
    COUNT(Type) as count,
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY  average_mean DESC;
-- found out a few have significantly low count 


-- Filtering out where count is less than 100 to prevent outliers

SELECT 
	Type, 
    COUNT(Type) as count,
    round(AVG(Mean),1) as average_mean, 
    round(AVG(Median),1) as average_median
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
	ON hi.id = hs.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY  average_mean DESC;
-- Borough, Track and CDP record the highest average


-- Looking up what states have 'community' as a type because the mean and median is really low compared to the others (Just Curious)

SELECT * 
FROM  us_household_income_project.ushouseholdincome
WHERE TYPE = 'community';
-- discovered it is Puerto Rico


-- identifying  total state land/water area alongside average household income to check whether physically larger states earn more
SELECT 
    hi.State_Name,
    SUM(hi.ALand) AS total_land_area,
    SUM(hi.AWater) AS total_water_area,
    ROUND(AVG(hs.Mean), 2) AS avg_mean_income,
    ROUND(AVG(hs.Median), 2) AS avg_median_income
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
    ON hi.id = hs.id
WHERE hs.Mean <> 0
GROUP BY hi.State_Name
ORDER BY total_land_area DESC;


-- Limiting to see top 10
SELECT 
    hi.State_Name,
    SUM(hi.ALand) AS total_land_area,
    SUM(hi.AWater) AS total_water_area,
    ROUND(AVG(hs.Mean), 2) AS avg_mean_income,
    ROUND(AVG(hs.Median), 2) AS avg_median_income
FROM us_household_income_project.ushouseholdincome hi
INNER JOIN us_household_income_project.ushouseholdincome_statistics hs
    ON hi.id = hs.id
WHERE hs.Mean <> 0
GROUP BY hi.State_Name
ORDER BY total_land_area DESC
LIMIT 10;
-- Large states by land area (such as Texas and California) do not lead in average household income.
-- Note: Land/water sums here reflect only tracts with non-zero reported income.



