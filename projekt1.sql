WITH prumernamzda as (
SELECT 
ROUND (AVG(cp.value)::numeric,0) as AvgPerYear, industry_branch_code , payroll_year
from czechia_payroll as cp
WHERE unit_code = '200' and calculation_code = '200' and value IS NOT NULL and value_type_code  = '5958' and industry_branch_code IS NOT NULL
group by payroll_year, industry_branch_code
order by 
cp.payroll_year, industry_branch_code
)
SELECT
payroll_year, name,
avgperyear - (LAG (avgperyear) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year))
 as Differences
FROM
prumernamzda as pm JOIN  czechia_payroll_industry_branch as cpib on pm.industry_branch_code = cpib.code
ORDER BY 
Differences;

