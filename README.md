# E-Commerce Sales & Customer Analytics

## Overview

End-to-end analysis of Brazilian e-commerce transaction data using
PostgreSQL and Power BI.

The project analyses sales performance, product performance, customer
behaviour, payment patterns and customer retention.

## Tools

- PostgreSQL
- SQL
- Power BI
- DAX
- Power Query

## Dashboard

### Sales Overview

![Sales Overview](E-Commerce%20project%202026/Images/Sales_Overview.png)

### Customer & Retention Analysis

![Customer Retention](E-Commerce%20project%202026/Images/Customer_and_Retention_Analysis.png)

## Analysis

The project includes:

- Monthly revenue and month-over-month growth analysis
- Product category and geographic sales analysis
- Customer spending and repeat-purchase analysis
- Cohort retention analysis
- Payment-method and installment analysis
- Data-quality validation

## Key Findings

- Delivered orders account for the overwhelming majority of realised sales.
- Revenue increased substantially across the observed period.
- Sales are geographically concentrated, particularly in São Paulo.
- Credit cards are the dominant payment method.
- Repeat purchasing and monthly cohort retention are relatively low.
- Higher-installment credit-card purchases tend to have higher average
  payment values.

## Methodology

Transactional CSV files were loaded into PostgreSQL and modelled across
customers, orders, order items, products, category translations and payments.

SQL was used for data validation and analysis. Delivered orders were used
for final realised-sales metrics.

A PostgreSQL view was created for cohort retention analysis and imported
into Power BI alongside the core tables.

Power BI was then used to build the data model, DAX measures and two-page
interactive dashboard.

## Repository Structure

- `sql/` – SQL cleaning, analysis and view creation
- `powerbi/` – Power BI dashboard
- `images/` – Dashboard previews

## Dataset

Brazilian E-Commerce Public Dataset by Olist, available on Kaggle.
