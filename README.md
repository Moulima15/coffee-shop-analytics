# Coffee Shop Sales Analysis

## 📊 Project Overview
This project involves a comprehensive analysis of a coffee shop's sales data. Using SQL for data extraction and transformation, and Power BI for visualization, this dashboard provides key insights into sales trends, product performance, customer behavior, and peak business hours.

## 📁 Project Files

This repository contains all the necessary files to understand and replicate the analysis:

*   `coffee_sales.sql`: The SQL file containing the database schema, sample data, and analytical queries used for this analysis.
*   `coffee_sales.csv`: The raw dataset used for the analysis.
*   `coffee_sales.pbix`: The Power BI desktop file containing the data model, calculations, and interactive visualizations.
*   `coffee_sales.pdf`: An exported PDF report of the interactive Power BI dashboard for quick viewing.

## 🗃️ Database Schema
The analysis is built on a single main table, created from the provided CSV file:

**Table: `coffee`**
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_date` | DATE | Date of the order |
| `order_time` | TIME | Time of the order |
| `hour_of_day` | INT | Hour of the day (0-23) |
| `cash_type` | CHAR(10) | Payment method ('cash' or 'card') |
| `card` | VARCHAR(50) | Customer identifier |
| `money` | DECIMAL(10,2) | Transaction amount |
| `coffee_name` | CHAR(30) | Name of the coffee product sold |
| `Time_of_day` | CHAR(20) | Categorization of time (Morning, Afternoon, Night) |
| `week_day` | CHAR(20) | Name of the weekday |
| `month_name` | CHAR(10) | Name of the month |
| `weekdaysort` | INT | Numeric value for weekday sorting |
| `monthsort` | INT | Numeric value for month sorting |

## 🔍 Key Insights & Analysis
The SQL queries and Power BI dashboard explore several key business questions:

1.  **Top Customers**: Identification of the highest-spending customers in the last 6 months.
2.  **Sales Trends**: Daily sales revenue with a 7-day moving average to identify trends.
3.  **Product Popularity**: Most popular coffee type by time of day (Morning, Afternoon, Night).
4.  **Purchase Frequency**: Average number of days between customer orders.
5.  **Payment Trends**: Monthly analysis of cash vs. card payment preferences and their growth rates.
6.  **Top Products by Weekday**: Best-selling coffee for each day of the week.
7.  **Customer Segmentation**: Grouping customers into High, Medium, and Low spenders.
8.  **RFM Analysis**: Identifying top 5% of high-value customers based on Recency, Frequency, and Monetary value.

## 📈 How to Use
1.  **Database Setup**: Run the `coffee_sales.sql` script in a MySQL environment to create the database and table. Use the `coffee_sales.csv` file as the data source.
2.  **Interactive Dashboard**: Open the `coffee_sales.pbix` file with Power BI Desktop to explore the interactive dashboard (requires Power BI installed).
3.  **Quick Report**: View the `coffee_sales.pdf` for a static snapshot of the dashboard insights.

## 🛠️ Tools Used
*   **SQL** (MySQL): For database management and data analysis.
*   **Power BI**: For creating interactive visualizations and dashboards.
