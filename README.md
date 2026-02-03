# Data Engineering Assessment

## Overview
This repository demonstrates how I approach designing and communicating a scalable analytics data model from raw source data through analytics-ready outputs. The goal of the exercise is not just to transform data, but to show how architectural decisions, data quality handling, and tradeoffs are made intentionally and grounded in the characteristics of the source data. All artifacts in this repo are designed to reflect how I would structure and explain a real-world data engineering project.

## Problem Framing
This repository demonstrates how I approach designing and communicating a scalable analytics data model from raw source data through analytics-ready outputs. The goal of the exercise is not just to transform data, but to show how architectural decisions, data quality handling, and tradeoffs are made intentionally and grounded in the characteristics of the source data. All artifacts in this repo are designed to reflect how I would structure and explain a real-world data engineering project.


## Architecture Summary

- Source data originates from Salesforce (Customers, Orders) and NetSuite (Products) and is ingested into Postgres via Fivetran pipelines.
- Raw source tables are modeled in dbt using a staging layer to enforce source-level assumptions such as grain, deduplication, and column selection.
- Analytics-ready fact and dimension tables are built directly from staging models using a star schema optimized for reporting and analysis.
- The resulting models are designed to be consumed by Tableau, with clean join paths and clearly defined grains to prevent fan-out and ensure reliable metrics.


## Analytical Schema
- **Customers** represent unique business entities sourced from Salesforce Accounts.
- **Orders** represent individual jobs/orders sourced from Salesforce Jobs and are modeled at one row per `order_id`.
- **Products** represent sellable items sourced from NetSuite Pricebook and are modeled at one row per `product_id`.


- The **primary fact table grain** is one row per `order_id`, with each order associated to a single product.
- Customer-level attributes are modeled as a dimension and joined to facts via `customer_id`.
- Product-level attributes are modeled as a dimension and joined to facts via `product_id`.

## Transformation Approach
All raw source tables (customers, orders, and products) are first modeled in a staging layer. The staging models enforce source-level assumptions such as grain, deduplication (where required), and basic column selection, providing a clean and consistent foundation for downstream fact and dimension models.


## Data Quality & Governance
The Customers source contains exact duplicate rows for the same `customer_id`. These are treated as ingestion artifacts and are deduplicated in the staging layer (`stg_customers`) to retain a single row per customer_id.

In production, data quality issues would be operationalized through automated checks and alerts. Duplicate detection and enforcement of correct grain occur in the staging layer. Critical null checks (such as missing primary or foreign keys and required dates) would be implemented as tests and configured to alert on failure. Late-arriving or updated records would be handled via incremental processing based on timestamp fields (e.g., `updated_at`) so downstream models automatically reconcile changes without requiring full reloads.


## Scalability & Automation

Initial data loads would be performed as full refreshes to establish a complete baseline. Once stabilized, models would transition to incremental processing using timestamp fields (such as `updated_at`) to efficiently process new or changed records. Pipeline health would be monitored via model execution status and data freshness checks, with alerts configured for failures or stale data. Schema evolution would be managed by introducing new fields in the staging layer first and propagating changes downstream in a controlled manner to minimize breaking changes.


## Tradeoffs & Design Decisions
An intermediate layer was not introduced due to the simplicity and clarity of the source grain. This can be added if business logic becomes reusable or more complex.

## How to Review This Repo
