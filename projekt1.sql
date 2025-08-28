/*Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/


WITH prumernamzda as (
SELECT 
ROUND (AVG(cp.value)::numeric,0) as AvgPerYear, industry_branch_code , payroll_year
FROM czechia_payroll as cp
WHERE unit_code = '200' AND calculation_code = '200' AND value IS NOT NULL and value_type_code  = '5958' and industry_branch_code IS NOT NULL
GROUP BY payroll_year, industry_branch_code
ORDER BY 
cp.payroll_year, industry_branch_code
)
SELECT
payroll_year, name,code, 
avgperyear - (LAG (avgperyear) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year))
 AS Differences
FROM
prumernamzda as pm JOIN  czechia_payroll_industry_branch as cpib on pm.industry_branch_code = cpib.code
ORDER BY 
Differences;

 /* Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední 
 * srovnatelné období v dostupných datech cen a mezd?*/

WITH CenyPrumer as (
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
	ORDER BY payroll_year
	)
SELECT
	AVG(value) as PrumCenaZaJednotku, cpr.year, cpr.price_quarter, cpr.category_code, cpc.name, prumernamzda, ROUND ((prumernamzda/AVG(value))::numeric, 0) as PocetZakoupenychJednotek
	from CenyPrumer cpr
	join czechia_price_category as cpc on cpr.category_code=cpc.code
	join VypocetPrumerneMzdy as vpm on vpm.payroll_year=cpr.year and vpm.payroll_quarter=cpr.price_quarter 
	where cpr.category_code in ('111301','114201') and ((cpr.year = '2006' and cpr.price_quarter = '1') or (cpr.year = '2018' and cpr.price_quarter = '4'))
	group by year, price_quarter, category_code, cpc.name, prumernamzda 
	order by cpc.name, year, price_quarter , category_code;


