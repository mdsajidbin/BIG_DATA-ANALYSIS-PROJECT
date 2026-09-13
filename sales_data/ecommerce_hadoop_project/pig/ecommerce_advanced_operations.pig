-- ==========================================
-- Operation 1: High-Value Orders Filter
-- ==========================================
order_revenue = FOREACH sales GENERATE order_id, customer_id, (price * quantity) AS total_order_value;
high_value_orders = FILTER order_revenue BY total_order_value > 5000;
STORE high_value_orders INTO '/ecommerce/pig_output/high_value_orders_filtered' USING PigStorage(',');

-- ==========================================
-- Operation 2: Most Popular Payment Method
-- ==========================================
payment_group = GROUP sales BY payment_method;
payment_counts = FOREACH payment_group GENERATE group AS payment_method, COUNT(sales) AS num_transactions;
STORE payment_counts INTO '/ecommerce/pig_output/payment_method_counts' USING PigStorage(',');

-- ==========================================
-- Operation 3: Top 3 Cities by Total Items Sold
-- ==========================================
city_group_qty = GROUP sales BY city;
city_total_qty = FOREACH city_group_qty GENERATE group AS city, SUM(sales.quantity) AS total_quantity;
sorted_cities = ORDER city_total_qty BY total_quantity DESC;
top_3_cities = LIMIT sorted_cities 3;
STORE top_3_cities INTO '/ecommerce/pig_output/top_3_cities_by_quantity' USING PigStorage(',');