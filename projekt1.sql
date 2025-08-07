SELECT 
cp.payroll_year , ROUND (AVG(cp.value)::numeric,2) as AvgPerYear, cpib.name
FROM
czechia_payroll as cp 
LEFT JOIN czechia_payroll_industry_branch as cpib on cp.industry_branch_code = cpib.code
WHERE 
cp.value_type_code = '5958'
AND 
cp.unit_code = '200'
AND
cp.calculation_code ='200'
AND cp.value IS NOT NULL
AND cp.industry_branch_code IS NOT NULL
GROUP BY
cpib.name, cp.payroll_year
ORDER BY 
cpib.name, cp.payroll_year;

WITH czechia_payroll_rozdeleno AS 
(SELECT
*, CASE WHEN value_type_code = 316 then value
ELSE null
END AS zamestnanci, 
CASE WHEN value_type_code = 5958 then value
ELSE null
END AS mzda 
FROM
czechia_payroll as cp )
SELECT
*
FROM
czechia_payroll_rozdeleno as cpr
WHERE 
zamestnanci IS NOT NULL;


, ROUND (AVG(cp.value)::numeric,0) as AvgPerYear,

SELECT
SUM(mzda*zamestnanci)/zamestnanci as VazenyPrumer


SELECT cp.industry_branch_code, cp.payroll_year , cp.value from czechia_payroll as cp 
where cp.value_type_code = 316 and cp.value IS NOT NULL
group by cp.industry_branch_code , cp.value, cp.payroll_year
order by cp.industry_branch_code , cp.payroll_year 


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
*
FROM
prumernamzda as pm JOIN  czechia_payroll_industry_branch as cpib on pm.industry_branch_code = cpib.code
