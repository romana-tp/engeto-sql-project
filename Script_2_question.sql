/** Question 2: How many liters of milk and kilograms of bread could be purchased in the first and 
 * last comparable periods covered by the available price and wage data?**/



WITH yearly_pay AS (
    SELECT 
        payroll_year,
        AVG(avg_payroll) AS avg_payroll_all
    FROM 
    t_Romana_Tomeckova_project_SQL_primary_final
    GROUP BY 
    payroll_year
	),
price_per_product AS (
    SELECT 
        category_code,
        name_of_product,
        payroll_year,
        AVG(avg_price) AS avg_price
    FROM 
    	t_Romana_Tomeckova_project_SQL_primary_final
    GROUP BY 
    	category_code, 
    	name_of_product, 
    	payroll_year
	)
SELECT 
    ROUND(yp.avg_payroll_all / ppp.avg_price::numeric, 0) AS unit_count,
    ppp.category_code,
    ppp.name_of_product,
    ppp.payroll_year
FROM 
	price_per_product ppp
	LEFT JOIN yearly_pay yp
    	ON yp.payroll_year = ppp.payroll_year
WHERE 
	ppp.category_code IN (111301, 114201)
	AND ppp.payroll_year IN (2006, 2018)
ORDER BY 
	ppp.name_of_product;

