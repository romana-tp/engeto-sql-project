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
	category_code, name_of_product , 
	ROUND (AVG (percent)::numeric,2) as percent_growth
FROM 
	overview
GROUP BY
	category_code, name_of_product
ORDER BY
	percent_growth ASC
LIMIT 
	1;