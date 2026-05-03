# 🛒 RetailPulse — E-Commerce SQL Analytics Project

## Project Overview
A complete end-to-end SQL analytics project built on a
realistic e-commerce database. Designed, populated and
analysed using PostgreSQL to answer real business questions
across revenue, products, customers and operations.

---

## Database Schema
5 tables — 130+ rows of realistic sample data

```
customers → orders → order_items ← products ← categories
```

| Table | Rows | Description |
|---|---|---|
| categories | 8 | Product categories |
| products | 20 | Product catalogue |
| customers | 20 | Customer profiles |
| orders | 30 | Order transactions |
| order_items | 50 | Line items per order |

---

## Files in This Project

| File | Description |
|---|---|
| 01_create_db.sql | Create the retailpulse database |
| 02_schema.sql | All 5 CREATE TABLE statements with constraints |
| 03_data.sql | INSERT statements — realistic sample data |
| 04_intermediate_queries.sql | JOINs, subqueries, GROUP BY, CASE WHEN |
| 05_advanced_queries.sql | Window functions, CTEs, LAG/LEAD, RANK |
| 06_business_analysis.sql | KPIs, RFM, cohort analysis, retention |

---

## Key Business Questions Answered

### Revenue
- What is the overall business health snapshot?
- What does monthly and quarterly revenue trend look like?
- Which was the best and worst performing month?

### Products
- What are the top 5 best-selling products by revenue?
- Which products have never been sold (dead stock)?
- What is each category's share of total revenue?

### Customers
- How do customers segment by RFM score?
- What is the customer retention rate?
- How many days does it take a customer to place a second order?

### Operations
- What is the order fulfilment status breakdown?
- Which countries generate the most revenue?

---

## Key Findings

| Metric | Value |
|---|---|
| Total Revenue | $[your number] |
| Average Order Value | $[your number] |
| Customer Retention Rate | [your number]% |
| Top Product by Revenue | [your product name] |
| Top Category by Revenue | [your category name] |
| Best Revenue Month | [your month] |

---

## SQL Skills Demonstrated

- `JOIN` — INNER, LEFT across 3–4 tables simultaneously
- `GROUP BY` + `HAVING` — aggregation with conditional filtering
- `Subqueries` — nested and correlated
- `CASE WHEN` — customer tiering and segmentation
- `Window Functions` — ROW_NUMBER, RANK, LAG, SUM OVER
- `CTEs` — multi-step WITH clauses
- `RFM Analysis` — Recency, Frequency, Monetary segmentation
- `Cohort Analysis` — revenue tracking by signup month
- `Retention Analysis` — repeat buyer rate calculation

---

## Tools Used
- **Database:** PostgreSQL 15
- **Editor:** VS Code with SQLTools extension
- **Version Control:** Git + GitHub

---
      
## How to Run This Project
1. Install PostgreSQL and connect via VS Code SQLTools
2. Run `01_create_db.sql` to create the database
3. Run `02_schema.sql` to create all tables
4. Run `03_data.sql` to load sample data
5. Run any analysis file to explore the queries
