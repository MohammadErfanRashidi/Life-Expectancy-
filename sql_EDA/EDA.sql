-- Total number of rows
SELECT COUNT(*) AS total_rows FROM life_expectancy;

-- Number of distinct countries and years
SELECT
    COUNT(DISTINCT country) AS number_of_countries,
    COUNT(DISTINCT year) AS number_of_years,
    MIN(year) AS earliest_year,
    MAX(year) AS latest_year
FROM life_expectancy;

-- How many rows have percentage_expenditure of 0
SELECT COUNT(*) AS zero_perc
FROM life_expectancy
WHERE percentage_expenditure = 0;

-- Status difference 
SELECT
    status,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM life_expectancy), 1) AS percentage
FROM life_expectancy
GROUP BY status;

-- Average life expectancy per year
SELECT
    year,
    ROUND(AVG(life_expectancy), 2) AS avg_life_expectancy
FROM life_expectancy
GROUP BY year
ORDER BY year;

-- Average life expectancy per year, split by developed (1)/developing (0)
SELECT
    year,
    status,
    ROUND(AVG(life_expectancy), 2) AS avg_life_expectancy
FROM life_expectancy
GROUP BY year, status
ORDER BY year, status;

-- Top 10 countries by average life expectancy 
SELECT 
    country,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY country
ORDER BY avg_life DESC
LIMIT 10;

-- Bottom 10 counties
SELECT 
    country,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY country
ORDER BY avg_life ASC
LIMIT 10;

-- Life expectancy vs. GDP
SELECT
    CASE 
        WHEN gdp < 1000 THEN '1. low'
        WHEN gdp BETWEEN 1000 AND 5000 THEN '2. medium'
        WHEN gdp BETWEEN 5001 AND 20000 THEN '3. high'  
        ELSE '4. very high'
    END AS gdp_cat,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY gdp_cat
ORDER BY gdp_cat;

-- Life vs. Schooling
SELECT
    CASE 
        WHEN schooling < 6 THEN 'Less than 6 years'
        WHEN schooling BETWEEN 6 AND 19 THEN '6-10 years'
        WHEN schooling BETWEEN 10.1 AND 14 THEN '10-14 years'
        ELSE '+14 years'
    END AS schooling_group,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY schooling_group
ORDER BY avg_life;

-- Life vs. Alcohol 
SELECT
    CASE 
        WHEN alcohol < 2 THEN 'Low'
        WHEN alcohol BETWEEN 2 AND 6 THEN 'Moderate'
        ELSE 'High'
    END AS alcohol_level,
    ROUND(AVG(life_expectancy), 2) AS avg_life,
    COUNT(*) AS countries_count
FROM life_expectancy
GROUP BY alcohol_level
ORDER BY avg_life;

-- Adult mortality
SELECT
    CASE 
        WHEN adult_mortality < 150 THEN '1. Low'
        WHEN adult_mortality BETWEEN 150 AND 300 THEN '2. Medium'
        WHEN adult_mortality BETWEEN 301 AND 500 THEN '3. High'  
        ELSE '4. Very High'
    END AS mortality_group,
    ROUND(AVG(life_expectancy), 2) AS avg_life,
    COUNT(*) AS num_records
FROM life_expectancy
GROUP BY mortality_group
ORDER BY avg_life DESC;

-- Infant deaths
SELECT
    CASE 
        WHEN infant_deaths < 10 THEN '1. Very low'
        WHEN infant_deaths BETWEEN 10 AND 100 THEN '2. Low'
        WHEN infant_deaths BETWEEN 101 AND 500 THEN '3. Medium'  
        ELSE '4. High'
    END AS infant_deaths_group,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY infant_deaths_group
ORDER BY avg_life DESC;

-- BMI on Life
SELECT
    CASE 
        WHEN bmi < 20 THEN 'Underweight'
        WHEN bmi BETWEEN 20 AND 50 THEN 'Normal'  
        ELSE 'Overweight'
    END AS bmi_group,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY bmi_group;

-- Income on Life
SELECT
    CASE 
        WHEN income_composition_of_resources < 0.5 THEN 'Low'
        WHEN income_composition_of_resources BETWEEN 0.5 AND 0.7 THEN 'Medium'
        ELSE 'High'
    END AS icr_group,
    ROUND(AVG(life_expectancy), 2) AS avg_life
FROM life_expectancy
GROUP BY icr_group;