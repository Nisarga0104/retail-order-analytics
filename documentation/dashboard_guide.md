\# Retail Order Analytics – Dashboard Guide



\## 1. Project Overview



The Retail Order Analytics dashboard provides a consolidated view of retail business performance using a synthetic retail dataset.



It was developed using Power BI Desktop, with MySQL as the data source.



The dashboard helps analyze sales performance, customer purchasing behaviour, product performance, payment activity, inventory levels, and shipment operations.



\## 2. Dashboard Structure



The dashboard is organized into three main analytical areas:



\- \*\*Executive KPIs:\*\* High-level business performance indicators.

\- \*\*Sales and Customer Insights:\*\* Revenue trends, category performance, product performance, customer contributions, and geographic sales distribution.

\- \*\*Order and Operational Insights:\*\* Order statuses, payment methods, and shipment statuses.



\## 3. Key Performance Indicators (KPIs)



| KPI | Description |

|---|---|

| Net Sales | Total sales value after applying item-level discounts. |

| Total Orders | Number of unique orders. |

| Total Customers | Number of unique customers. |

| Average Order Value | Net sales divided by total orders. |

| Completed Payments | Total value of payments with Completed status. |

| On-Time Delivery Rate | Percentage of delivered shipments delivered on or before the estimated delivery date. |

| Return Rate | Percentage of distinct order items with return records. |

| Low Stock Products | Number of products at or below their reorder level. |

| Cancelled Orders | Number of orders with Cancelled status. |



\## 4. Analytical Visualizations



\### Sales Performance

\- Monthly Net Sales Trend

\- Sales by Product Category

\- Sales by State

\- Top 10 Products by Sales



\### Customer Insights

\- Top 10 Customers by Net Sales



\### Order and Operational Analysis

\- Order Status Distribution

\- Payment Method Distribution

\- Shipment Status Distribution



\## 5. Data Model



The Power BI data model contains nine relational tables:



1\. Customers

2\. Categories

3\. Suppliers

4\. Products

5\. Orders

6\. Order Items

7\. Payments

8\. Shipments

9\. Returns



Relationships were created using primary and foreign key columns to support analysis across the retail business.



\## 6. Tools and Technologies



\- MySQL

\- MySQL Workbench

\- Power BI Desktop

\- Power Query

\- DAX

\- Microsoft Excel / CSV



\## 7. Important Data Considerations



\- The dataset is synthetic and intended for portfolio and analytical demonstration purposes.

\- The available sales data covers June and July only.

\- Net Sales is calculated from order item quantities, unit prices, and discounts.

\- Completed Payments represents recorded payments with Completed status and is not interchangeable with Net Sales.

\- Return Rate considers distinct order items with return records, regardless of return status.

\- On-Time Delivery Rate considers delivered shipments with valid actual and estimated delivery dates.



\## 8. Business Value



The dashboard demonstrates how relational retail data can be transformed into business-oriented performance indicators and visual insights.



It supports analysis of revenue performance, customer contribution, product demand, payment activity, inventory risks, order cancellations, and delivery performance.

