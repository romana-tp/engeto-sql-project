/*Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/


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
payroll_year, name,code, 
avgperyear - (LAG (avgperyear) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year))
 as Differences
FROM
prumernamzda as pm JOIN  czechia_payroll_industry_branch as cpib on pm.industry_branch_code = cpib.code
ORDER BY 
Differences;

 /* Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední 
 * srovnatelné období v dostupných datech cen a mezd?*/

WITH cistka as 
	(SELECT 
	value, 
	category_code, 
	date_part('year', date_from) as Year
	FROM
	czechia_price as cp 
		where (category_code = '114201' and region_code IS NULL)
		OR (category_code = '111301' and region_code IS NULL)
	group by year, value, category_code
	order by year, category_code
	), 
VypocetPrumerneMzdy as (
	SELECT 
	payroll_year,
	payroll_quarter,
	AVG (value) as PrumernaMzda 
	from czechia_payroll 
	where value_type_code = '5958' 
	and unit_code = '200' 
	and calculation_code = '200' 
	and industry_branch_code is null and value is not null
	GROUP BY 
	payroll_year, payroll_quarter
	ORDER BY payroll_year)
SELECT
c.category_code, cpc.name, cpc.price_unit, c.comparing
from cistka as c
join czechia_price_category as cpc on c.category_code=cpc.code 
where comparing IS NOT NULL


SELECT 
MIN (date_from) as PrvniObdobi, 
MAX (date_to) as PosledniObdobi
FROM
czechia_price as cp 

SELECT payroll_year, AVG (value) as PrumernaMzda 
from czechia_payroll 
where value_type_code = '5958' 
and unit_code = '200' 
and calculation_code = '200' 
and industry_branch_code is null and value is not null
GROUP BY 
payroll_year
ORDER BY payroll_year 

with test as (
	SELECT 
	value, 
	category_code, 
	date_part('year', date_from) as year,
	CASE when TO_CHAR(date_from, 'MM-DD') BETWEEN '01-01' AND '03-31' then 1
	when TO_CHAR(date_from, 'MM-DD') BETWEEN '04-01' AND '06-30' then 2
	when TO_CHAR(date_from, 'MM-DD') BETWEEN '07-01' AND '09-30'then 3
	ELSE 4
	END AS price_quarter
	FROM
	czechia_price as cp 
		where  region_code IS NOT NULL
	group by  value, category_code, price_quarter , year
	order by  category_code
	)
SELECT
	AVG(value), test.year, test.price_quarter, test.category_code, cpc.name
	from test
	join czechia_price_category as cpc on test.category_code=cpc.code
	group by year, price_quarter, category_code, cpc.name
	order by cpc.name, year, price_quarter , category_code 


