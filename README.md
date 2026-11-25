# US-Household-Income Exploratory Data Analysis (MySQL)

📂 **[SQL Query](https://github.com/davmaane/US-Household-Income-Project-EDA/blob/main/US%20Household%20Income%20Project%20EDA.sql)** 

## Table of Contents
* [Project Overview](#Project-Overview)
* [Key Questions Answered](#Key-Questions-Answered)
* [Dataset Description](#Dataset-Description)
* [Tools Used](#Tools-Used)
* [Featured SQL Skills](#Featured-SQL-Skills)
* [Data Cleaning Summary](#Data-Cleaning-Summary)
* [Exploratory Data Analysis (EDA), Queries And Insights](#Exploratory-Data-Analysis-(EDA),-Queries-And-Insights)
* [Analytical Note](#Analytical-Note)
* [Recommendations](#Recommendations)
* [Limitations](#Limitations)


## Project Overview
This project focuses on an **SQL Exploratory Data Analysis (EDA)** of the **US Household Income dataset** which contains over 32,000+ US Census records. Using **MySQL**, I joined geographic location tables with household income statistics to uncover state-level wealth disparities, urban-vs-rural earnings gaps, and high-earner income skew across American cities—translating raw census records into clear market-targeting insights.

## Key Questions Answered 
- Which US states record the highest and lowest average household incomes?
- Which US Cities by States record the highest and lowest average household incomes?
- How do household earnings differ across location types?
- Does state land or water area correlate with higher average household income?
  

## Dataset Description
The datasets sourced from Kaggle, consists of two relational tables which is the income table which contains the income and Geographic dimension and then the statistics table which contains the Financial metrics like the mean and median. Both tables with over 32,000 rows contain a unique id column which could be used to link both tables to find trends and clear analysis

## Tools Used
SQL (MySQL Workbench)

## Featured SQL Skills
 Multi-table `INNER JOIN`s, Common Table Expressions (CTEs), Window Functions (`RANK()` / `DENSE_RANK()`), Aggregate Functions (`AVG()`, `SUM()`, `COUNT()`, `ROUND()`), `GROUP BY`, and `HAVING` clauses.

##  Data Cleaning Summary
Before running exploratory queries, both tables were standardized and prepared in MySQL. Key steps completed during the data cleaning process:
- Removed 6 duplicate records
- Text & Spelling Standardization on the 'State_name' and 'type' columns
- Handled missing values in the 'place' column
- Zero-Value Filtering: Excluded invalid `0` entries in `Mean` and `Median` income fields during statistical queries so unreported census tracts do not artificially lower state averages.
- Checked every other column to make sure the dataset is ready for analysis

  🔗 **[View the full Data Cleaning Project Process & before/after](https://github.com/davmaane/US-Household-Income-Project-DC)**

  

## Exploratory Data Analysis (EDA), Queries And Insights
### Insight 1: Top & Bottom States by Household Income
Joining the income and statistics tables while filtering out unreported (`0`) records shows clear income gaps across the States.
```sql
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
```
Result:   

<img width="532" height="240" alt="image" src="https://github.com/user-attachments/assets/1575f7c2-4ed5-4640-b8ad-6d75f9f78946" />

- **Top State, District of Columbia** leads with an average household income of **$90,668.4**, whereas **Lowest State, Puerto Rico** sits at **$27,841.7**, this highlights a gap of over **$62,000** between the highest and lowest earning States.

### Insight 2: Top & Bottom Cities by States by Household Income
Joining the income and statistics tables while filtering out unreported (`0`) records also shows clear income gaps across the Cities.
```sql
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
```
Result:  

<img width="605" height="242" alt="image" src="https://github.com/user-attachments/assets/05ab4733-8830-4be7-9626-ea5ac76bcc9b" />

- **Top City, Delta Junction(Alaska)** leads with an average household income of **$242,857.0**, whereas **Lowest City, Center(Colorado)** sits at **$10,946.0**, this highlights a gap of over **$231,000** between the highest and lowest earning Cities.

### Insight 3: Household Income by Community Type (`City` vs. `Town` vs. `Village`)
Grouping by Community Structure (`Type`) and applying a `HAVING` clause of over 100 records (`> 100`) gives a fair and clearer comparison.

```sql
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
-- Borough, Track and CDP records the highest average
```

Result:  


<img width="361" height="156" alt="image" src="https://github.com/user-attachments/assets/e829d324-828f-4fc1-9215-478d166a8350" />

- Household earnings vary significantly by community structure. Borough records the highest average household income at $68,594.4, outperforming Town at $55,194.1. This indicates stronger purchasing power concentrated in incorporated suburban and metropolitan census zones compared to smaller rural settlements.

### Insight 4: Land or Water area correlation with average household income?
Comparing total state land/water area alongside average household income to check whether physically larger states earn more:

```sql
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
```

Result:  


<img width="616" height="247" alt="image" src="https://github.com/user-attachments/assets/550fa25b-07aa-4ac5-9a5f-b75db5b24a12" />

- While massive states like Texas and California lead in total land area (ALand), smaller compact states such as District of Columbia, New Jersey, and Connecticut consistently rank higher in average household income. Similar with the high water area (AWater) in states like Michigan, confirming that economic density and industry concentration matter far more than physical land mass.


## Analytical Note 
While District of Columbia leads all states at over $90,000 average income, individual cities such as Delta Junction (Alaska) exceed $242,000 because they represent isolated, high-income census tracts with very few records, whereas Alaska's statewide average is balanced out by hundreds of lower-income rural communities.

## Recommendations
1. **Use Median Income Instead of Average (Mean) for Pricing:** A few ultra-wealthy households pull the average income way up in certain cities. Businesses setting product prices or loan limits should use **Median income** so they don't overestimate what a typical family can actually afford.
2. **Focus on High-Income Cities, Not Big States:** A physically large state does not mean wealthier residents. Companies launching premium products should target high-earning metro areas (like **District of Columbia, Connecticut, and New Jersey**) rather than choosing markets based on land size.
3. **Filter Out Empty Rows and Tiny Towns in Future Reports:** Anyone analyzing this census dataset should always exclude `0` income rows and towns with very few records (`COUNT >= 10`) so missing data and isolated outliers don't distort the results.


---

## Limitations 
* Records with `0` values for `Mean` and `Median` income had to be excluded to preserve statistical accuracy.
