/**Create a table with payroll and prices for Czech republic which includes comparable period of time**/



CREATE TABLE t_Romana_Tomeckova_project_SQL_primary_final AS
	WITH payroll AS (
		SELECT 
			ROUND (AVG(cp.value)::numeric,2) AS avg_payroll, 
			cpib.name, 
			cp.payroll_year, 
			cp.industry_branch_code
		FROM 
			czechia_payroll AS cp
			JOIN czechia_payroll_industry_branch AS cpib 
			ON cp.industry_branch_code = cpib.code
		WHERE 
			unit_code = 200
			AND calculation_code = 200
			AND value IS NOT NULL 
			AND value_type_code  = 5958
			AND industry_branch_code IS NOT NULL
	GROUP BY 
		cpib.code, 
		cp.payroll_year,  
		cp.industry_branch_code
	ORDER BY 
		cp.payroll_year, cpib.name
	), 
price AS (
		SELECT 
			ROUND (AVG (cp.value)::numeric, 2) AS avg_price, 
			cp.category_code, 
			name AS name_of_product,
			date_part ('year',date_from) AS price_year
		FROM
			czechia_price AS cp 
			JOIN czechia_price_category AS cpc 
			ON cp.category_code=cpc.code
		WHERE  
			region_code IS NOT NULL
		GROUP BY   
			cp.category_code, 
			price_year, 
			name_of_product
	)
SELECT
	avg_payroll, 
	name, 
	industry_branch_code, 
	payroll_year, 
	avg_price, 
	name_of_product, 
	category_code
FROM
	payroll 
	LEFT JOIN price 
	ON payroll.payroll_year=price.price_year 
GROUP BY
	avg_payroll, 
	name, 
	payroll_year, 
	name_of_product,
	avg_price,
	industry_branch_code, 
	category_code;

SELECT * from t_Romana_Tomeckova_project_SQL_primary_final