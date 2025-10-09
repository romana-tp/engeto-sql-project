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
SELECT 
    name_of_product,
    COUNT(DISTINCT price_year) AS years_overview
FROM 
	test_food
GROUP BY 
	name_of_product
ORDER BY 
	years_overview; -- "Jakostní víno bílé" has data just for 4 years

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
	ROUND((
		(Yearly_pay - LAG (yearly_pay) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_pay) OVER (ORDER BY price.payroll_year))*100 
		)::numeric, 2
    ) as percent_pay, 
	ROUND ((
		(yearly_price-LAG (yearly_price) OVER (ORDER BY price.payroll_year))
			/(LAG (yearly_price) OVER (ORDER BY price.payroll_year))*100 
		)::numeric, 2
    ) as percent_price, 
	ROUND ((
		((yearly_price-LAG (yearly_price) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_price) OVER (ORDER BY price.payroll_year))*100) 
		- ((Yearly_pay - LAG (yearly_pay) OVER (ORDER BY price.payroll_year))
		/(LAG (yearly_pay) OVER (ORDER BY price.payroll_year))*100) 
		)::numeric, 2
    ) as Difference_Percent
FROM
	price 
	JOIN pay 
	ON price.payroll_year=pay.payroll_year
ORDER BY
	difference_percent DESC;
