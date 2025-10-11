/** Question 5: Does the level of GDP affect changes in wages and food prices? In other words, 
 * if GDP increases significantly in a given year, does this lead to a noticeably higher increase 
 * in wages or food prices in the same or the following year?**/



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
	gdp_1 AS (
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
	gdp_2 AS (
		SELECT 
			year, 
			LAG (gdp_growth_percent_last_year) OVER (ORDER BY year) as gdp_growth_percent_last_year2
		FROM gdp_1
	)
SELECT
	ROUND (corr (gdp_growth_percent_last_year, percentpay)::numeric,2) AS correlation_with_payroll, 
	ROUND (corr (gdp_growth_percent_last_year, percentprice)::numeric, 2) AS correlation_with_price, 
	ROUND (corr (gdp_growth_percent_last_year2, percentpay):: numeric,2) AS correlation_with_payroll_2y, 
	ROUND (corr (gdp_growth_percent_last_year2, percentprice)::numeric,2) AS correlation_with_price2y
FROM 
	gdp_2 JOIN gdp_1 
		ON gdp_2.year=gdp_1.year;