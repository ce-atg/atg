# Data Engineering Assessment

## Overview

## Problem Framing

## Architecture Summary

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

## Tradeoffs & Design Decisions
An intermediate layer was not introduced due to the simplicity and clarity of the source grain. This can be added if business logic becomes reusable or more complex.

## How to Review This Repo
