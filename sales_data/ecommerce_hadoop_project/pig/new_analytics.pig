-- Load CSV data
sales = LOAD '/ecommerce/inputs/sales_data.csv' USING PigStorage(',') 
AS (order_id:chararray, order_date:chararray, customer_id:chararray, customer_name:chararray, city:chararray, product_id:chararray, product_name:chararray, category:chararray, quantity:int, unit_price:double, revenue:double, payment_method:chararray);

clean_sales = FILTER sales BY order_id != 'order_id' AND quantity IS NOT NULL;

-- ============================================
-- Pig Operation 1: Top 5 Highest Generating Orders
-- ============================================
high_value_orders = FILTER clean_sales BY revenue > 1500.0;
high_value_sorted = ORDER high_value_orders BY revenue DESC;
top_5_orders = LIMIT high_value_sorted 5;

STORE top_5_orders INTO '/ecommerce/pig_output/top_5_orders' USING PigStorage(',');

-- ============================================
-- Pig Operation 2: Average Revenue Per Order by City
-- ============================================
city_group = GROUP clean_sales BY city;
city_avg_revenue = FOREACH city_group GENERATE group AS City, AVG(clean_sales.revenue) AS Avg_Revenue_Per_Order;

STORE city_avg_revenue INTO '/ecommerce/pig_output/city_avg_revenue' USING PigStorage(',');

-- ============================================
-- Pig Operation 3: Total Products Sold by Each Customer
-- ============================================
customer_group = GROUP clean_sales BY customer_name;
customer_purchases = FOREACH customer_group GENERATE group AS Customer_Name, SUM(clean_sales.quantity) AS Total_Items_Bought;

STORE customer_purchases INTO '/ecommerce/pig_output/customer_purchases' USING PigStorage(',');