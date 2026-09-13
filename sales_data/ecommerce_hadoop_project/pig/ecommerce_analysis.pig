-- ============================================
-- E-Commerce Sales Data Analysis Using Pig
-- ============================================

-- Load CSV data
sales = LOAD '/ecommerce/inputs/sales_data.csv'
USING PigStorage(',')
AS (
    order_id:chararray,
    order_date:chararray,
    customer_id:chararray,
    customer_name:chararray,
    city:chararray,
    product_id:chararray,
    product_name:chararray,
    category:chararray,
    quantity:int,
    unit_price:double,
    revenue:double,
    payment_method:chararray
);

-- Remove header / invalid rows
clean_sales = FILTER sales BY order_id != 'order_id'
    AND quantity IS NOT NULL
    AND revenue IS NOT NULL
    AND category IS NOT NULL;

-- ============================================
-- 1. Total Revenue
-- ============================================

total_revenue_group = GROUP clean_sales ALL;

total_revenue_result = FOREACH total_revenue_group
    GENERATE SUM(clean_sales.revenue) AS Total_Revenue;

STORE total_revenue_result
INTO '/ecommerce/pig_output/total_revenue'
USING PigStorage(',');

-- ============================================
-- 2. Revenue by Category
-- ============================================

category_group = GROUP clean_sales BY category;

category_revenue = FOREACH category_group
    GENERATE group AS Category,
    SUM(clean_sales.revenue) AS Revenue;

STORE category_revenue
INTO '/ecommerce/pig_output/category_revenue'
USING PigStorage(',');

-- ============================================
-- 3. Revenue by City
-- ============================================

city_group = GROUP clean_sales BY city;

city_revenue = FOREACH city_group
    GENERATE group AS City,
    SUM(clean_sales.revenue) AS Revenue;

STORE city_revenue
INTO '/ecommerce/pig_output/city_revenue'
USING PigStorage(',');

-- ============================================
-- 4. Quantity Sold by Category
-- ============================================

category_quantity = FOREACH category_group
    GENERATE group AS Category,
    SUM(clean_sales.quantity) AS Total_Quantity;

STORE category_quantity
INTO '/ecommerce/pig_output/category_quantity'
USING PigStorage(',');

-- ============================================
-- 5. Average Unit Price by Category
-- ============================================

category_avg_price = FOREACH category_group
    GENERATE group AS Category,
    AVG(clean_sales.unit_price) AS Average_Unit_Price;

STORE category_avg_price
INTO '/ecommerce/pig_output/category_avg_price'
USING PigStorage(',');

-- ============================================
-- 6. Revenue by Payment Method
-- ============================================

payment_group = GROUP clean_sales BY payment_method;

payment_revenue = FOREACH payment_group
    GENERATE group AS Payment_Method,
    SUM(clean_sales.revenue) AS Revenue,
    COUNT(clean_sales) AS Total_Orders;

STORE payment_revenue
INTO '/ecommerce/pig_output/payment_revenue'
USING PigStorage(',');

-- ============================================
-- 7. Total Quantity Sold (Overall)
-- ============================================

total_quantity_group = GROUP clean_sales ALL;

total_quantity_result = FOREACH total_quantity_group
    GENERATE SUM(clean_sales.quantity) AS Total_Quantity_Sold;

STORE total_quantity_result
INTO '/ecommerce/pig_output/total_quantity'
USING PigStorage(',');