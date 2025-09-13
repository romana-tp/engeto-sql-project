# SQL Project for Engeto Data Academy

Intro: A project focused on assessing the availability of basic foodstuffs to the general public.

Note: There was a mistake in the original dataset concerning the czechia_payroll_unit table, where the values "thousands of employees" and "CZK" were mixed up. I corrected this by setting the code 200 for Czech crowns (CZK) and the code 80403 for thousands of employees.

0. First of all, I created the primary table containing price and payroll data for the Czech Republic. Using temporary tables, I extracted the data for average payroll within industry branches, filtered by the following conditions: unit_code = 200 (values in CZK), calculation_code = 200 (to account for full-time equivalent units rather than the headcount of employees), and value_type_code = 5958 (representing average payroll).

Next, I prepared a table for the average prices of basic foodstuffs. Finally, I joined both tables and calculated average values by year and by quarter. I chose this approach because one of my research questions involved comparing specific time periods (the earliest and the most recent), and by structuring the data this way I was able to compare not only entire years but also corresponding quarters.

1. Research question no.1: Do salaries increase across all industry branches, or are there any decreases as well?

Since the complete data on employee counts for each year was not available, I decided to calculate unweighted averages. Using a Common Table Expression (CTE), I prepared the average yearly wages. Then, by applying the LAG function, I created a new column that shows year-to-year differences. Ordering the results by these values allowed me to answer the first research question.

Answer: There are a few industry branches and payroll years where we can see a decrease. Specifically, we talk about 32 cases. The biggest decrease happened in 2013 in Financial services and Insurance Industry (code K) - there was a 4 484 CZK decrease comparing to the previous year.


2. Research question no. 2: How many liters of milk and kilograms of bread can be purchased in the first and last comparable periods in the available price and wage data?



Answer: According to the resulting table, in the first comparable period (the first quarter of 2006), it was possible to buy 1,252 units (kg) of bread, and in the last period (the fourth quarter of 2018), 1,426 units (kg) of bread.
In the same periods, it was possible to purchase 1,284 units (liters) of milk in the first period, and 1,749 units (liters) of milk in the second period.


3. Research question no. 3: Which category of food has the slowest price increase (i.e., the lowest year-on-year percentage growth)? Is there a year in which the year-on-year increase in food prices was significantly higher than wage growth (by more than 10%)?

