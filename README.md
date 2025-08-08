# SQL Project for Engeto Data Academy

Here is an intro to my SQL project for Engeto Data Academy. 

Poznámka o chybě v tisících zaměstnanců. V korunách v calculation Code nebo unit Code


1. Resarch question no.1: Do salaries increase across all industry branches, or are there any decreases as well?

Since the full data on employee counts for each year is not available, I decided to calculate unweighted averages. First, I created a temporary table (by using CTE) and joined it with another one containing the names of the industry branch codes. Using the LAG function, I created a new column showing the differences between years. By ordering the results by these values, I was able to answer the first question.

Ansnwer: There are a few industry branches and payroll years where we can see a decrease. Specifically, we talk about 32 cases. The biggest decrease happened in 2013 in Financial services and Insurance Industry (code K) - there was a 4 484 CZK decrease comparing to the previous year.