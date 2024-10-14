SELECT * FROM retail_events_db.dim_products;
SELECT dp.product_name, fe.base_price, fe.promo_type FROM dim_products AS dp INNER JOIN 
fact_events AS fe ON dp.product_code=fe.product_code WHERE fe.base_price > 500 
AND fe.promo_type = "BOGOF";

-- Creating Tab for High Value Discounted Products--
CREATE TABLE high_value_discounted_products AS 
SELECT dp.product_name, fe.base_price, fe.promo_type FROM dim_products AS dp INNER JOIN 
fact_events AS fe ON dp.product_code=fe.product_code WHERE fe.base_price > 500 
AND fe.promo_type = "BOGOF";

-- Creating Table for Stores in Cities

CREATE TABLE stores_in_city AS SELECT city, COUNT(store_id) AS store_count FROM dim_stores
GROUP BY store_id, city ORDER BY store_id DESC;

-- Changing Column names --
ALTER TABLE fact_events
CHANGE `quantity_sold(after_promo)` quantity_sold_after_promo INT;
ALTER TABLE fact_events
CHANGE `quantity_sold(before_promo)` quantity_sold_before_promo INT;

-- Calculating Total Revenue before and after Promo --

CREATE TABLE revenue_pre_post_promotion AS SELECT dc.campaign_name,
sum(fe.quantity_sold_before_promo * base_price) AS 
total_revenue_before_promotion,
sum(fe.quantity_sold_after_promo * base_price) AS total_revenue_after_promotion 
FROM fact_events AS fe JOIN dim_campaigns AS dc
ON dc.campaign_id=fe.campaign_id
GROUP BY dc.campaign_name;


SELECT 
dp.category,  SUM(fe.quantity_sold_before_promo) / 
(SELECT SUM(fe2.quantity_sold_after_promo) FROM fact_events AS fe2) * 100 AS percentage_increment
FROM dim_products AS dp JOIN  fact_events AS fe ON dp.product_code = fe.product_code
GROUP BY dp.category ORDER BY percentage_increment DESC;

SELECT 
dp.product_name, dp.category, 
(SUM(fe.quantity_sold_after_promo) - SUM(fe.quantity_sold_before_promo)) / 
SUM(fe.quantity_sold_before_promo) * 100 AS percentage_increment
FROM dim_products AS dp JOIN  fact_events AS fe 
ON dp.product_code = fe.product_code GROUP BY dp.product_name, dp.category
ORDER BY percentage_increment DESC;



