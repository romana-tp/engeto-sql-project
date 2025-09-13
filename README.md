# SQL Project for Engeto Data Academy

Intro: A project focused on assessing the availability of basic foodstuffs to the general public.

Note: There was a mistake in the original dataset concerning the czechia_payroll_unit table, where the values "thousands of employees" and "CZK" were mixed up. I corrected this by setting the code 200 for Czech crowns (CZK) and the code 80403 for thousands of employees.

0. First of all, I created the primary table containing price and payroll data for the Czech Republic. Using temporary tables, I extracted the data for average payroll within industry branches, filtered by the following conditions: unit_code = 200 (values in CZK), calculation_code = 200 (to account for full-time equivalent units rather than the headcount of employees), and value_type_code = 5958 (representing average payroll).

Next, I prepared a table for the average prices of basic foodstuffs. Finally, I joined both tables and calculated average values by year and by quarter. I chose this approach because one of my research questions involved comparing specific time periods (the earliest and the most recent), and by structuring the data this way I was able to compare not only entire years but also corresponding quarters.

1. Research question no.1: Do salaries increase across all industry branches, or are there any decreases as well?

Since the complete data on employee counts for each year was not available, I decided to calculate unweighted averages. Using a Common Table Expression (CTE), I prepared the average yearly wages. Then, by applying the LAG function, I created a new column that shows year-to-year differences. Ordering the results by these values allowed me to answer the first research question.

Answer: There are a few industry branches and payroll years where we can see a decrease. Specifically, we talk about 32 cases. The biggest decrease happened in 2013 in Financial services and Insurance Industry (code K) - there was a 4 484 CZK decrease comparing to the previous year.


2. Research question no. 2: How many liters of milk and kilograms of bread can be purchased in the first and last comparable periods in the available price and wage data?

First, using CTEs, I created temporary tables summarizing the average wages and the prices of bread and milk for each quarter. Then, I joined these tables and selected the first and last quarters from the available data. I also added a calculation of how many units of these products could be purchased with the average wage.

Answer: According to the resulting table, in the first comparable period (the first quarter of 2006), it was possible to buy 1,371 kilograms of bread, and in the last period (the fourth quarter of 2018), 1,470 kilograms of bread.
During the same periods, it was possible to purchase 1,407 liters of milk in the first period, and 1,803 liters of milk in the last period.


3. Research question no. 3: Which category of food has the slowest price increase (i.e., the lowest year-on-year percentage growth)? 

Using a CTE, I prepared a table with the average yearly prices of food products. I also calculated the year-on-year price growth in percentages using the LAG window function. From the resulting selection, I then identified the single value representing the product with the slowest average price increase.

Answer: The lowest year-on-year growth was observed for the category White Crystal Sugar, which, on average, decreased in price by 1.9% over the entire available period.


4. Research question no. 4: Is there a year in which the year-on-year increase in food prices was significantly higher than wage growth (by more than 10%)?

I was not sure if I had all years data for all food products, so I checked it with 

I first calculated average yearly food prices (yearly_price) excluding category 212101 (because "Wine" has just data for several years, but not the whole period from 2006 to 2018) and average yearly wages (yearly_pay) using CTEs. Using the LAG() window function, I computed the year-on-year percentage changes for both wages (percentpay) and food prices (percentprice). I then calculated the difference between the price growth and wage growth (DifferencePercent) to identify years where price increases exceeded wage growth. Finally, I ordered the results by DifferencePercent in descending order.

Answer: There is no year in the available data where the year-on-year increase in food prices exceeded wage growth by more than 10%. The closest was 2013, when food prices grew about 7% faster than wages. However, if we consider only the growth in food prices themselves, in 2017 prices increased by more than 10%, which was higher than the wage growth of approximately 6% that year.


5. Research question no. 5: Does the level of GDP affect changes in wages and food prices? In other words, if GDP increases significantly in a given year, does this lead to a noticeably higher increase in wages or food prices in the same or the following year?

By using CTEs, I calculated the average yearly wages (yearly_pay) and average yearly food prices (yearly_price) excluding category 212101 (because of the same reason as in the previous case - I did not want to influence data by adding the "Wine" product which lacks values for several years). I also prepared a table with yearly GDP for the Czech Republic. Using the LAG() window function, I calculated year-on-year percentage changes for wages, prices, and GDP. Additionally, I created a 2-year lag for GDP to see if GDP growth affects wages or prices with a delay. Finally, I calculated correlations between GDP growth and the growth of wages and prices:

GDP growth appears to have a stronger effect on wages than on food prices, particularly when considering a 1-year lag (correlation of 0.44 in the same year and 0.68 with a one-year lag). Food prices do not show a clear delayed response to changes in GDP.


