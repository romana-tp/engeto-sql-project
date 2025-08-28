# SQL Project for Engeto Data Academy

Intro: A project focused on assessing the availability of basic foodstuffs to the general public.

Note: There was a mistake in the original dataset regarding "Calculation code" and "Unit code", which had to be corrected. Values - "thousands of employees" and "CZK" was mixed.


1. Resarch question no.1: Do salaries increase across all industry branches, or are there any decreases as well?

Since the full data on employee counts for each year is not available, I decided to calculate unweighted averages. First, I created a temporary table (by using CTE) and joined it with another one containing the names of the industry branch codes. Using the LAG function, I created a new column showing the differences between years. By ordering the results by these values, I was able to answer the first question.

Ansnwer: There are a few industry branches and payroll years where we can see a decrease. Specifically, we talk about 32 cases. The biggest decrease happened in 2013 in Financial services and Insurance Industry (code K) - there was a 4 484 CZK decrease comparing to the previous year.

2. Research question no. 2: How many liters of milk and kilograms of bread can be purchased in the first and last comparable periods in the available price and wage data?

Answer: According to the resulting table, in the first comparable period (the first quarter of 2006), it was possible to buy 1,252 units (kg) of bread, and in the last period (the fourth quarter of 2018), 1,426 units (kg) of bread.
In the same periods, it was possible to purchase 1,284 units (liters) of milk in the first period, and 1,749 units (liters) of milk in the second period.