# Snowflake AI Showcase: Cortex-Powered Analytics

## Overview

This document demonstrates how Snowflake Cortex AI can be integrated into a data analytics platform to automatically generate business insights, answer natural language questions, and help stakeholders understand their data without writing SQL.

**Key Capabilities Demonstrated:**
- Natural language query generation using Cortex AI
- Automated business insight generation from analytical queries
- Practical applications for executive reporting and decision-making
- Production-ready patterns for AI-powered data analysis

---

## Architecture
**Data Flow:**

1. Raw Data (Customers, Orders, Products)
2. dbt Staging Layer
3. dbt Intermediate Layer  
4. dbt Marts Layer (Facts & Dimensions)
5. Snowflake Cortex AI Layer (AI-powered insights)
6. Business Users / Dashboards
