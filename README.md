# Data Engineering Assessment

## Overview

## Problem Framing

## Architecture Summary

## Analytical Schema
- **Customers** represent unique business entities sourced from Salesforce Accounts.
- **Orders** represent individual jobs/orders sourced from Salesforce Jobs.
- **Products** represent sellable items sourced from NetSuite Pricebook.

- The **primary fact table grain** is one row per order per product.
- Customer-level attributes are modeled as a dimension and joined to facts via `customer_id`.
- Product attributes are modeled as a dimension and joined to facts via `product_id`.


## Transformation Approach

## Data Quality & Governance
The Customers source contains exact duplicate rows for the same `customer_id`. These are treated as ingestion artifacts and are deduplicated in the staging layer (`stg_customers`) to retain a single row per customer_id.



## Scalability & Automation

## Tradeoffs & Design Decisions

## How to Review This Repo
