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

**Example Usage:**
```sql
-- Question: "How many orders have null values in total_amount?"
SELECT answer_data_question('How many orders have null values in total_amount?');
-- Returns: SELECT COUNT(*) FROM ORDERS WHERE total_amount IS NULL;

-- Question: "What is the total revenue by product category?"
SELECT answer_data_question('What is the total revenue by product category?');
-- Returns: SELECT p.category, SUM(o.total_amount) as revenue
--          FROM ORDERS o JOIN PRODUCTS p ON o.product_id = p.product_id
--          GROUP BY p.category;
```

**Business Value:**
- Reduces dependency on data analysts for ad-hoc queries
- Enables self-service analytics for business users
- Provides transparency (users see the SQL before execution)
- Educational tool for learning SQL patterns

---

## Use Case 2: Automated Business Insights

### Order Status Analysis

Automatically generate executive summaries from order pipeline metrics.

**Query:**
```sql
SELECT 
    status,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-8b',
        CONCAT(
            'We have ', COUNT(*)::STRING, ' ', status, ' orders worth $', 
            SUM(total_amount)::STRING, 
            '. Write one sentence about what this means for business operations.'
        )
    ) as business_insight
    
FROM orders
WHERE total_amount IS NOT NULL
GROUP BY status;
```

**Results:**

| Status | Order Count | Total Revenue | AI-Generated Insight |
|--------|-------------|---------------|---------------------|
| Completed | 10,455 | $6,509,333.56 | "The company has achieved a significant milestone with 10,455 completed orders, totaling $6,509,333.56 in revenue, indicating a substantial increase in sales and operational efficiency." |
| Pending | 2,918 | $1,767,563.17 | "The company has a significant backlog of 2,918 pending orders totaling $1,767,563.17, indicating a substantial volume of work that needs to be fulfilled in order to meet customer demand and potentially impact production and fulfillment timelines." |
| Cancelled | 1,477 | $945,536.61 | "The high number of cancelled orders, totaling $945,536.61, indicates a significant disruption to business operations, potentially resulting in lost revenue, wasted resources, and a need for reassessment of sales strategies and inventory management." |

**Key Insights:**
- Completed orders show strong operational efficiency (70% of total orders)
- Pending orders represent $1.7M in fulfillment backlog requiring attention
- Cancelled orders ($945K) signal potential issues in sales process or product availability

---

### Product Category Performance Analysis

Generate insights about category-level performance for merchandising decisions.

**Query:**
```sql
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(o.total_amount), 2) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-8b',
        CONCAT(
            'The ', p.category, ' category had ', COUNT(DISTINCT o.order_id)::STRING, 
            ' orders generating $', ROUND(SUM(o.total_amount), 2)::STRING, 
            ' in revenue, with an average order value of $', ROUND(AVG(o.total_amount), 2)::STRING,
            '. Write one insight about this category performance in one sentence.'
        )
    ) as ai_insight
    
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.total_amount IS NOT NULL
GROUP BY p.category
ORDER BY total_revenue DESC;
```

**Results:**

| Category | Orders | Revenue | Avg Order Value | AI-Generated Insight |
|----------|--------|---------|-----------------|---------------------|
| Books | 2,473 | $1,618,524.05 | $654.48 | "The Books category saw a significant revenue generation of $1,618,524.05 from 2,473 orders, indicating a strong demand for books and a relatively high average order value of $654.48." |
| Beauty | 2,553 | $1,566,373.21 | $613.54 | "The Beauty category saw a significant revenue generation of $1,566,373.21 from 2,553 orders, resulting in an average order value of $613.54." |
| Apparel | 2,558 | $1,561,206.52 | $610.32 | "The Apparel category saw a significant revenue performance, with an average order value of $610.32, indicating a strong average transaction size that contributed to the overall revenue of $1,561,206.52." |
| Toys | 2,466 | $1,548,395.62 | $627.90 | "The Toys category saw a significant revenue generation of $1,548,395.62 from 2,466 orders, resulting in an average order value of $627.90." |
| Electronics | 2,442 | $1,529,278.13 | $626.24 | "The Electronics category saw a significant revenue generation of $1,529,278.13 from 2,442 orders, indicating a strong demand for electronic products." |
| Home | 2,358 | $1,398,655.81 | $593.15 | "The Home category saw a significant revenue generation of $1,398,655.81 from 2,358 orders, indicating a strong demand for home-related products." |

**Key Insights:**
- Books leads in revenue ($1.62M) with highest average order value ($654)
- Order volume is well-balanced across categories (2,358-2,558 orders each)
- Home category has lowest AOV ($593) - potential opportunity for upselling
- All categories show strong performance - diversified revenue stream reduces risk

---

## Production Implementation Considerations

### Cost Management
- Cortex AI charges per token (input + output)
- Llama 3.1-8b: ~$0.11 per 1M input tokens, ~$0.30 per 1M output tokens
- Example cost for category analysis: ~$0.01 per execution (6 categories)
- Implement incremental processing to reduce costs at scale

### Integration with dbt
```sql
-- Example: Add AI insights as a calculated column in mart models
SELECT 
    order_id,
    customer_id,
    product_id,
    total_amount,
    SNOWFLAKE.CORTEX.COMPLETE('llama3.1-8b', 
        'Summarize this order in one sentence: ' || order_details
    ) as ai_summary
FROM {{ ref('fct_orders') }}
{% if is_incremental() %}
WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}
```

### Best Practices
1. **Prompt Engineering**: Be specific in prompts to get consistent outputs
2. **Caching**: Store AI-generated insights to avoid re-processing unchanged data
3. **Monitoring**: Track token usage and costs with Snowflake query history
4. **Validation**: Always review AI outputs before surfacing to end users

---

## Comparison: CORTEX.COMPLETE vs Cortex Analyst

| Feature | CORTEX.COMPLETE (This Demo) | Cortex Analyst |
|---------|----------------------------|----------------|
| **Purpose** | General-purpose LLM for custom workflows | Purpose-built for SQL generation |
| **Setup** | Simple function calls | Requires semantic model (YAML) |
| **Semantic Layer** | Prompt-based context | YAML-defined business logic |
| **Execution** | Returns text/SQL | Returns results + SQL |
| **Best For** | Developers, custom AI workflows | Business users, self-service BI |
| **Availability** | All Snowflake accounts | Enterprise Edition, specific regions |

---

## Conclusion

This showcase demonstrates practical applications of Snowflake Cortex AI for:
1. **Self-Service Analytics**: Natural language query generation reduces analyst bottlenecks
2. **Automated Insights**: AI-generated business commentary scales executive reporting
3. **Production Integration**: Patterns align with modern dbt-based data stacks
4. **Cost-Effective AI**: Native Snowflake integration eliminates external API overhead

**Business Impact:**
- Faster time-to-insight for business stakeholders
- Reduced dependency on data analysts for routine questions
- Automated narrative generation for dashboards and reports
- Foundation for advanced AI use cases (recommendations, predictions, anomaly detection)

---

