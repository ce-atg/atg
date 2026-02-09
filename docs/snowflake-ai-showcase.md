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

**Why Snowflake Cortex?**
- Native integration with Snowflake (no external API calls)
- Enterprise-grade security (data never leaves Snowflake)
- Cost-effective (pay only for compute used)
- Multiple LLM options (Arctic, Llama, Mistral)
- Production-ready with RBAC support

---

## Use Case 1: Natural Language Query Assistant

### Function: answer_data_question()

Allows business users to ask questions in plain English and receive SQL queries they can execute.

**Implementation:**
```sql
CREATE OR REPLACE FUNCTION answer_data_question(question STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
  SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'snowflake-arctic',
    CONCAT(
      'You are a data analyst. Given this schema, generate SQL to answer the question.
      
      Tables in ATG.PUBLIC:
      - CUSTOMERS (customer_id, first_name, last_name, email, city, state, country, created_at, updated_at)
      - ORDERS (order_id, customer_id, product_id, quantity, order_date, status, total_amount)
      - PRODUCTS (product_id, product_name, category, price, created_at, updated_at)
      
      Question: ', question, '
      
      Return ONLY the SQL query, no explanation or markdown.'
    )
  )
$$;
```
