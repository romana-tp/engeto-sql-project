# SQL Project for Engeto Data Academy

**Intro:**  
A project focused on assessing the availability of basic foodstuffs to the general public.
This project was created as part of the SQL project of the Data Academy and focuses on preparing data foundations for analyzing the availability of basic food products in the Czech Republic based on the development of average wages over time. The analysis is based on data from the Czech Open Data Portal (particularly the `czechia_payroll` and `czechia_price` tables) and supplementary datasets about European countries (`economies`, `countries`). The task involved creating two final tables – a primary one (`t_romana_tomeckova_project_SQL_primary_final`) combining information on wages and food prices in the Czech Republic, and a secondary one (`t_romana_tomeckova_project_SQL_secondary_final`) containing macroeconomic indicators (GDP, GINI coefficient, population) of other European countries. Using these datasets, SQL queries were developed to answer research questions focused on wage trends, food price changes, their interrelation, and the potential impact of GDP growth. 

**Note:**  
There was a mistake in the original dataset concerning the `czechia_payroll_unit` table, where the values "thousands of employees" and "CZK" were mixed up. I corrected this by setting the code `200` for Czech crowns (CZK) and the code `80403` for thousands of employees.

---

## Script 0. Data preparation and primary and secondary table creation

First of all, I created the primary table containing price and payroll data for the Czech Republic (`t_Romana_Tomeckova_project_SQL_primary_final`). Using temporary tables, I extracted the data for average payroll within industry branches, filtered by the following conditions: 

- `unit_code = 200` (values in CZK)  
- `calculation_code = 200` (to account for full-time equivalent units rather than the headcount of employees)  
- `value_type_code = 5958` (representing average payroll)  

Next, I prepared a table for the average prices of basic foodstuffs. I joined both tables and calculated average values by **year** and by **quarter**. I chose this approach because one of my research questions involved comparing specific time periods (the earliest and the most recent), and by structuring the data this way I was able to compare not only entire years but also corresponding quarters.

Finally, by joining two additional tables `economies` and `countries`, I created secondary table with macroeconomics data (`t_Romana_Tomeckova_project_SQL_secondary_final`) with various information about countries around the world, such as the capital city, currency, national dish, or average population height as well as GDP, GINI index, tax burden, etc., for a given country and year.

---

## 1. Research Question 1

**Question:** Do salaries increase across all industry branches, or are there any decreases as well?

Since the complete data on employee counts for each year was not available, I decided to calculate unweighted averages. Using a Common Table Expression (CTE), I prepared the average yearly wages. Then, by applying the `LAG` function, I created a new column that shows year-to-year differences. Ordering the results by these values allowed me to answer the first research question.

**Answer:**  
There are a few industry branches and payroll years where we can see a decrease. Specifically, there are **32 cases**. The biggest decrease happened in **2013** in the Financial Services and Insurance Industry (code K) — a decrease of **4,484 CZK** compared to the previous year. On the other hand, the biggest increase happened in the Health and social care field in 2021 - it was 6,159 CZK.

---

## 2. Research Question 2

**Question:** How many liters of milk and kilograms of bread can be purchased in the first and last comparable periods in the available price and wage data?

First, using CTEs, I created temporary tables summarizing the average wages and the prices of bread and milk for each quarter. Then, I joined these tables and selected the first and last quarters from the available data. I also added a calculation of how many units of these products could be purchased with the average wage.

**Answer:**  
In **2006**, with the average wage, it was possible to purchase approximately **1,313 kilograms of bread** or **1,670 liters of milk**. By **2018**, the purchasing power had changed slightly — an average wage could buy around **1,365 kilograms of bread** and **1,404 liters of milk**.

This means that over the observed period, the affordability of bread improved a little, as people could buy slightly more bread for their wages. In contrast, the affordability of milk declined, since the number of liters that could be purchased with the average wage decreased.

Overall, while average wages increased over time, the relative prices of these basic food items evolved differently — resulting in a modest gain in purchasing power for bread but a noticeable loss for milk.

---

## 3. Research Question 3

**Question:** Which category of food has the slowest price increase (i.e., the lowest year-on-year percentage growth)?

Using a CTE, I prepared a table with the average yearly prices of food products. I also calculated the year-on-year price growth in percentages using the `LAG` window function. From the resulting selection, I then identified the single value representing the product with the slowest average price increase.

**Answer:**  
The analysis shows that among all the monitored food categories, ** White Crystal Sugar**  experienced the slowest price growth over the observed period. In fact, its price did not rise at all on average — it decreased by approximately ** 1.9% year-on-year** .

This means that, unlike most other food products whose prices generally increased over time, sugar became slightly cheaper on average. The negative growth rate indicates that its price was either stable or even declined in some years. Overall, White Crystal Sugar stands out as the only category where the long-term trend shows a reduction rather than an increase in consumer prices.

---

## 4. Research Question 4

**Question:** Is there a year in which the year-on-year increase in food prices was significantly higher than wage growth (by more than 10%)?

Note: I was not sure if data for all food products was available for every year, so I checked it using a helper table called test_food. I found that one product — Wine — lacked data for several years, with values available only for 4 years.

I first calculated average yearly food prices (`yearly_price`) excluding category 212101 (because "Wine" has incomplete data) and average yearly wages (`yearly_pay`) using CTEs. Using the `LAG()` window function, I computed the year-on-year percentage changes for both wages (`percentpay`) and food prices (`percentprice`). I then calculated the difference (`DifferencePercent`) to identify years where price increases exceeded wage growth. Finally, I ordered the results by `DifferencePercent` in descending order.

**Answer:**  
Based on the analysis, **there is no year** in the available dataset where the year-on-year growth in average food prices exceeded the growth in average wages by more than 10%. This indicates that, overall, wage increases kept pace with or outpaced food price inflation during the observed period.

The largest difference between food price growth and wage growth occurred in **2013**, when food prices rose **roughly 7% faster than wages**. This suggests that, in that year, the purchasing power of consumers temporarily declined, as food became more expensive relative to people’s earnings.

It is also worth noting that in **2017**, while the difference between the two growth rates was smaller, the food price growth itself **exceeded 10%**, whereas wage growth in that same year was around **6%**. This means that food prices experienced a notable surge even though overall wages were still increasing.

---

## 5. Research Question 5

**Question:** Does the level of GDP affect changes in wages and food prices? In other words, if GDP increases significantly in a given year, does this lead to a noticeably higher increase in wages or food prices in the same or the following year?

Within this question, I created secondary table with data about GDP in Czech Republic and other countries (`t_Romana_Tomeckova_project_SQL_secondary_final`). Then, by using CTEs, I calculated the average yearly wages (`yearly_pay`) and average yearly food prices (`yearly_price`), again excluding category 212101. I also prepared a table with yearly GDP for the Czech Republic. Using the `LAG()` window function, I calculated year-on-year percentage changes for wages, prices, and GDP. Additionally, I created a 1-year lag for GDP to see if GDP growth affects wages or prices with a delay. Finally, I calculated correlations between GDP growth and the growth of wages and prices.

**Answer:**  
The results indicate that GDP growth has a stronger influence on wages than on food prices. The correlation between GDP and wages is **0.44** in the same year and increases to **0.68 with a one-year lag**, suggesting that wage growth often follows GDP growth with a short delay.

In contrast, food prices show no clear or consistent link to GDP changes, meaning that their development depends more on other factors such as production costs, agricultural conditions, or global market trends.

Overall, when the economy grows, wages tend to rise — especially in the following year — but food prices react much less to these changes.
