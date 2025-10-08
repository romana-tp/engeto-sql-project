/** Question 1: Do payrolls increase across all industries over the years,
 *  or do some industries experience a decline?**/

WITH avg_per_year AS (
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
