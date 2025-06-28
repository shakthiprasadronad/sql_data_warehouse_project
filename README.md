## SQL_Data_Warehouse_Project
**Building a modern data warehouse with SQL server, Including ETL processes, data modeling and analytics**
>-----

>Understand what is a Readme.md file first - .md means markdown,
>
>*Well, This is my first ever project, Below things are for my understanding when i comeback here to refer*
>
>**What is Markdown ?**
>see[Markdown](www.markdownlink.com)
>
>Markdown is a lightweight markup language
>-----
>
>## List of tips
>1. *one asterisk italicizes*
>
>2. **Tow asterisks emphasize**
>-----

## Welcome to **Data Warehouse and Analytics Project** repository!

This project demonstrates a comprehensive data warehousing and anlytics solution, 
from building a data warehouse to generating actionable insights, 
designed as a portfolio project and highlights industry best practices in data engineering and analytics

---

## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](https://github.com/shakthiprasadronad/sql_data_warehouse_project/blob/main/docs/DWH_Medallion_Structure.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---


## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.
>
>This clean and detailed repository is an excellent resource for to follow best practices for any data architecture
>
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---

## 🚀 Project Requirements

**Building the Data Warehouse (Data Engineering)**

**Objective**
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

**Specifications**
- **Data Sources:** Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historization of data is not required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

--

## BI: Analytics & Reporting (Data Analysis)

**Objective:**

Develop SQL-based analytics to deliver detailed insights into:

**Customer Behavior:**

- Product Performance
- Sales Trends
- These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

