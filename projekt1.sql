/**Create a table with payroll and prices for Czech republic which includes comparable period of time**/


CREATE TABLE t_Romana_Tomeckova_project_SQL_primary_final AS
	WITH payroll AS (
		SELECT 
			ROUND (AVG(cp.value)::numeric,0) AS avg_payroll, 
			cpib.name, 
			cp.payroll_year, 
			cp.payroll_quarter, 
			cp.industry_branch_code
		FROM 
			czechia_payroll AS cp
			JOIN czechia_payroll_industry_branch AS cpib 
			ON cp.industry_branch_code = cpib.code
		WHERE 
			unit_code = '200' 
			AND calculation_code = '200' 
			AND value IS NOT NULL 
			AND value_type_code  = '5958' 
			AND industry_branch_code IS NOT NULL
	GROUP BY 
		cpib.code, 
		cp.payroll_year, 
		cp.payroll_quarter, 
		cp.industry_branch_code
	ORDER BY 
		cp.payroll_year, cpib.name
	), 
price AS (
		SELECT 
			cp.value, 
			cp.category_code, 
			name AS name_of_product,
			date_part ('year',date_from) AS price_year,
			CASE WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '01-01' AND '03-31' THEN 1
			WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '04-01' AND '06-30' THEN 2
			WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '07-01' AND '09-30'THEN 3
			ELSE 4
			END AS price_quarter
		FROM
			czechia_price AS cp 
			JOIN czechia_price_category AS cpc 
			ON cp.category_code=cpc.code
		WHERE  
			region_code IS NOT NULL
		GROUP BY  
			cp.value, 
			cp.category_code, 
			price_quarter, 
			price_year,
			name_of_product
		ORDER BY  
			cp.category_code
	)
SELECT
	avg_payroll, 
	name, 
	industry_branch_code, 
	payroll_year, 
	payroll_quarter, 
	AVG (value) AS avg_price, 
	name_of_product, 
	category_code
FROM
	payroll 
	LEFT JOIN price 
	ON payroll.payroll_year=price.price_year 
	AND payroll.payroll_quarter=price.price_quarter
GROUP BY
	avg_payroll, 
	name, 
	payroll_year, 
	payroll_quarter, 
	name_of_product, 
	industry_branch_code, 
	category_code;

SELECT * from t_Romana_Tomeckova_project_SQL_primary_final

/** Question 1: Do payrolls increase across all industries over the years,
 *  or do some industries experience a decline?**/

WITH avg_per_year AS 
	(
	SELECT DISTINCT
		avg_payroll, 
		payroll_year, 
		name
	FROM 
		t_Romana_Tomeckova_project_SQL_primary_final as payroll_and_price
	GROUP BY 
		avg_payroll, 
		payroll_year, 
		name
	ORDER BY
		payroll_year, name
	)
SELECT
	AVG(avg_payroll) - (LAG (AVG(avg_payroll)) OVER (PARTITION BY name ORDER BY payroll_year)) AS Differences, 
	name, 
	payroll_year
FROM
	avg_per_year
GROUP BY 
	payroll_year, name
ORDER BY 
	Differences;


/** Question 2: How many liters of milk and kilograms of bread could be purchased in the first and 
 * last comparable periods covered by the available price and wage data?**/


WITH quarter_pay AS (
	SELECT
		AVG (avg_payroll) as avg_payroll_all, 
		payroll_year, 
		payroll_quarter
	FROM 
		t_Romana_Tomeckova_project_SQL_primary_final as payroll_and_price
	GROUP BY
		payroll_year, payroll_quarter
	)
, quarter_price AS (
	SELECT
		category_code,
        name_of_product,
        payroll_year,
        payroll_quarter,
        AVG(avg_price) AS avg_price_all
    FROM 
    	t_Romana_Tomeckova_project_SQL_primary_final as payroll_and_price 
    GROUP BY 
    	category_code, name_of_product, payroll_year, payroll_quarter
    	)
SELECT 
	ROUND (qp.avg_payroll_all / qpr.avg_price_all::numeric,0) as Unit_Count, 
	qpr.category_code, 
	qpr.name_of_product, 
	qp.payroll_year, 
	qp.payroll_quarter
FROM
	quarter_pay qp 
		LEFT JOIN 
		quarter_price qpr 
		ON qp.payroll_year= qpr.payroll_year and qp.payroll_quarter = qpr.payroll_quarter
WHERE
	qpr.category_code IN ('111301','114201') 
	AND ((qp.payroll_year = 2006 and qp.payroll_quarter = 1) 
	OR (qp.payroll_year = 2018 and qp.payroll_quarter = 4));



/**Question 3: Which category of food has the slowest price increase (i.e., the lowest year-on-year percentage growth)? **/



WITH overview AS (
	SELECT
		category_code,
        name_of_product,
        payroll_year,
        (AVG(avg_price) 
        - LAG (AVG(avg_price)) OVER (PARTITION BY name_of_product ORDER BY payroll_year))
        /LAG (AVG(avg_price))  OVER (PARTITION BY name_of_product ORDER BY payroll_year)*100 as percent
    FROM 
    	t_Romana_Tomeckova_project_SQL_primary_final AS payroll_and_price
    GROUP BY 
    	category_code, name_of_product, payroll_year
    HAVING
    	name_of_product IS NOT NULL
    	)
SELECT 
	category_code, name_of_product , AVG (percent) as percent_growth
FROM 
	overview
GROUP BY
	category_code, name_of_product
ORDER BY
	percent_growth ASC
LIMIT 
	1;


/**4. Research question no. 4: Is there a year in which the year-on-year increase in food prices 
 * was significantly higher than wage growth (by more than 10%)?**/

/**Note: Check for potential missing data across all time periods**/

WITH test_food AS (
	SELECT 
		cp.value, 
		cp.category_code, name AS name_of_product,
		date_part ('year',date_from) AS price_year,
		CASE WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '01-01' AND '03-31' THEN 1
		WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '04-01' AND '06-30' THEN 2
		WHEN TO_CHAR(date_from, 'MM-DD') BETWEEN '07-01' AND '09-30'THEN 3
		ELSE 4
		END AS price_quarter
	FROM
		czechia_price AS cp 
		JOIN czechia_price_category AS cpc 
			ON cp.category_code=cpc.code
	WHERE  
		region_code IS NOT NULL
	GROUP BY  
		cp.value, 
		cp.category_code, 
		price_quarter , 
		price_year,
		name_of_product
	ORDER BY  
		cp.category_code)
SELECT DISTINCT 
	name_of_product,
	price_year
FROM test_food; -- "Jakostní víno bílé" has data just for 2015-108 years

/**4. Research question no. 4: Is there a year in which the year-on-year increase in food prices 
 * was significantly higher than wage growth (by more than 10%)?**/

WITH price as 
	(
	SELECT 
		AVG(avg_price) as yearly_price, payroll_year
	FROM
		t_Romana_Tomeckova_project_SQL_primary_final AS payroll_and_price
	WHERE
		avg_price IS NOT NULL and category_code <>212101
	GROUP BY 
	payroll_year
	),
pay as(
	SELECT 
		AVG (avg_payroll) as yearly_pay, payroll_year
	FROM 
		t_Romana_Tomeckova_project_SQL_primary_final AS payroll_and_price
	GROUP BY 
		payroll_year)
SELECT
	price.payroll_year,
	(Yearly_pay - LAG (yearly_pay) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_pay) OVER (ORDER BY price.payroll_year))*100 as percentpay, 
	(yearly_price-LAG (yearly_price) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_price) OVER (ORDER BY price.payroll_year))*100 as percentprice, 
	((yearly_price-LAG (yearly_price) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_price) OVER (ORDER BY price.payroll_year))*100) 
		- ((Yearly_pay - LAG (yearly_pay) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_pay) OVER (ORDER BY price.payroll_year))*100) as DifferencePercent
FROM
	price 
	JOIN pay 
	ON price.payroll_year=pay.payroll_year
ORDER BY
	differencepercent DESC;



/** Question 5: Does the level of GDP affect changes in wages and food prices? In other words, 
 * if GDP increases significantly in a given year, does this lead to a noticeably higher increase 
 * in wages or food prices in the same or the following year?**/

/**Note: Create secondary table with data about other cuontries**/

CREATE TABLE t_Romana_Tomeckova_project_SQL_secondary_final AS (
	SELECT DISTINCT
		country, 
		year, 
		gdp
	FROM
		economies
	WHERE 
		gdp is not null
	GROUP BY 
		country, 
		year, 
		gdp
	ORDER BY
		country);
	
/**Skript for the research question**/

WITH price AS (
		SELECT 
			AVG(avg_price) AS yearly_price, 
			payroll_year
		FROM
			t_Romana_Tomeckova_project_SQL_primary_final AS payroll_and_price
		WHERE
			avg_price IS NOT NULL 
			AND category_code <>212101
		GROUP BY 
			payroll_year
		),
	pay AS(
		SELECT 
			AVG (avg_payroll) AS yearly_pay, 
			payroll_year
		FROM 
			t_Romana_Tomeckova_project_SQL_primary_final AS payroll_and_price
		GROUP BY 
			payroll_year), 
	yearly_gdp AS (
    	SELECT 
        	country,
        	year,
        	AVG(gdp) AS gdp
    	FROM 
    		t_Romana_Tomeckova_project_SQL_secondary_final
    	WHERE 
    		country LIKE 'Czec%'
    	GROUP BY 
    	country, 
    	year
	),
	gdp1 AS (
		SELECT
    		(Yearly_pay - LAG (yearly_pay) OVER (ORDER BY price.payroll_year))/(LAG (yearly_pay) OVER (ORDER BY price.payroll_year))*100 as percentpay, 
			(yearly_price-LAG (yearly_price) OVER (ORDER BY price.payroll_year))/(LAG (yearly_price) OVER (ORDER BY price.payroll_year))*100 as percentprice, 
    		year,
    		(gdp - LAG(gdp) OVER (PARTITION BY country ORDER BY year)) / LAG(gdp) OVER (PARTITION BY country ORDER BY year) * 100 AS gdp_growth_percent_last_year
		FROM 
			yearly_gdp 
			JOIN pay 
				ON pay.payroll_year=yearly_gdp.year 
			JOIN price 
				ON price.payroll_year=yearly_gdp.year
		WHERE 
			year BETWEEN 2006 AND 2018
	), 
	gdp2 AS (
		SELECT 
			year, 
			LAG (gdp_growth_percent_last_year) OVER (ORDER BY year) as gdp_growth_percent_last_year2
		FROM gdp1
	)
SELECT
	corr (gdp_growth_percent_last_year, percentpay) AS correlation_with_payroll, 
	corr (gdp_growth_percent_last_year, percentprice) AS correlation_with_price, 
	corr (gdp_growth_percent_last_year2, percentpay)AS correlation_with_payroll_2y, 
	corr (gdp_growth_percent_last_year2, percentprice) AS correlation_with_price2y
FROM 
	gdp2 JOIN gdp1 
		ON gdp2.year=gdp1.year;
