/**Create secondary table with information about other countries using two more tables: 
 * countries – Various information about countries around the world, such as the capital city, currency, national dish, or average population height.
 * economies – GDP, GINI index, tax burden, etc., for a given country and year.**/



CREATE TABLE t_Romana_Tomeckova_project_SQL_secondary_final AS (
	SELECT DISTINCT ON (e.country, e.year)
    	e.country,
    	e.year,
    	e.gdp,
    	e.population,
    	c.population_density,
    	e.gini,
   		e.taxes,
    	c.capital_city,
    	c.surface_area,
    	c.government_type,
    	c.currency_name,
    	c.religion,
    	c.national_dish,
    	c.avg_height,
    	c.life_expectancy
	FROM 
    	countries c
	LEFT JOIN economies e 
    	ON c.country = e.country
	WHERE 
    	e.gdp IS NOT NULL 
    	AND continent = 'Europe'
	);


