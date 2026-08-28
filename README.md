# Olist Brazilian Ecommerce Analysis

Sales performance and operational analysis of the public Olist Brazilian ecommerce dataset using SQL and Excel.

## Overview

This project analyses real order data from Olist covering approximately 100,000 orders between 2016 and 2018. The work focuses on commercial performance, regional patterns, product categories, delivery reliability, customer behaviour and payment trends.

## Dataset

- **Source:** [Brazilian Ecommerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Period:** September 2016 – August 2018
- **Tables used:** orders, order items, customers, products, payments, reviews, sellers, category translation

## Tools

- SQL (SQLite / PostgreSQL compatible)
- Excel

## Project structure

| File | Description |
|------|-------------|
| `olist_student_analysis.sql` | SQL queries used for the analysis |
| `Olist_Student_Workbook.xlsx` | Results, regional and category breakdowns, delivery metrics and insights |
| `Olist_Analysis_Report.pdf` | Full analysis report with findings and recommendations |

## Analysis scope

- Overall commercial metrics (orders, revenue, GMV, average order value)
- Monthly sales trends
- Revenue and volume by customer state
- Top product categories
- Delivery performance vs estimated dates
- Review score distribution
- Payment method mix
- One time vs repeat customers
- Freight cost as a share of product price by region

## Key findings

- Sao Paulo accounts for roughly 42% of product revenue
- About 97% of customers placed only one order
- Delivery performance is stronger in the South and Southeast; late deliveries are more common in the North and Northeast
- Leading categories by revenue: bed bath table, health beauty, sports leisure, furniture decor, computers accessories
- Credit card is the dominant payment method, often with installments
- Average review score is approximately 4.1 / 5

## How to reproduce

1. Download the dataset from Kaggle and extract the CSV files
2. Load the CSVs into a SQL database using the table names listed in the SQL file
3. Run the queries in `olist_student_analysis.sql`
4. Review results in the Excel workbook and the PDF report

## Recommendations summary

- Reduce geographic concentration by supporting growth outside Sao Paulo
- Improve retention to increase the share of repeat customers
- Address logistics performance in states with higher late delivery rates
- Protect inventory and seller quality in the top revenue categories
- Review freight and free shipping rules by region

## License
Dataset: CC BY-NC-SA 4.0 (Olist / Kaggle)  
