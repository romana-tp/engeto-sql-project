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


