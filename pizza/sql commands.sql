
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id  INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  

-- Data Cleaning 
SELECT * FROM customer_orders;

SELECT * FROM pizza_names;

SELECT * FROM runner_orders;

DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp
SELECT order_id,
  customer_id,
  pizza_id,
  CASE 
	WHEN exclusions = 'null' OR exclusions = ''  THEN NULL
	ELSE exclusions
  END as exclusions,
  CASE WHEN extras='' OR extras = 'null' THEN null
  ELSE extras
  END as extras,
  order_time 
  FROM customer_orders;
  
DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp
SELECT order_id, runner_id, 
CASE WHEN pickup_time ='' OR pickup_time = 'null' THEN null
ELSE pickup_time
END AS pickuptime, 
CASE 
WHEN distance='' OR distance = 'null' THEN null
WHEN distance LIKE '%km' THEN REPLACE(distance,'km','')
ELSE distance 
END AS distance_in_km, 
CASE 
WHEN duration='' OR duration ='null' THEN null
WHEN duration LIKE '%min' THEN REPLACE(duration,'min','')
WHEN duration LIKE '%mins' THEN REPLACE(duration,'mins','')
WHEN duration LIKE '%minute' THEN REPLACE(duration,'minute','') 
WHEN duration LIKE '%minutes' THEN REPLACE(duration,'minutes','')
ELSE duration
END as duration_in_min, 
CASE WHEN cancellation ='' OR cancellation = 'null' THEN null
ELSE cancellation
END as cancellation FROM runner_orders;

SELECT * FROM customer_orders_temp;

SELECT * FROM runner_orders_temp;


  CREATE TEMPORARY TABLE runner_orders_pre
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time = 'null' THEN null
		ELSE pickup_time
	END AS pick_up_time,
	CASE
		WHEN distance = 'null' THEN null
		ELSE regexp_replace(distance, '[a-z]+', '')
	END AS distance_km,
	CASE
		WHEN duration = 'null' THEN null
		ELSE regexp_replace(duration, '[a-z]+', '')
		END AS duration_mins,
	CASE
		WHEN cancellation = '' THEN null
		WHEN cancellation = 'null' THEN null
		ELSE cancellation
		END AS cancellation               
FROM runner_orders;

CREATE TEMPORARY TABLE runner_orders_post
	SELECT
		order_id,
		runner_id,
		pick_up_time,
		CAST(distance_km AS DECIMAL(3,1)) AS distance_km, 
		CAST(duration_mins AS SIGNED INT) AS duration_mins,
		cancellation
    FROM runner_orders_pre;
-- Case Study Questions

-- A. Pizza Metrics

-- 1.How many pizzas were ordered?
select count(*) as number_of_pizzas
from customer_orders;

-- 2.How many unique customer orders were made?
select count(distinct order_id) as unique_pizza_order
from customer_orders;

-- 3.How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS order_count
FROM runner_orders
WHERE duration IS NOT NULL
GROUP BY runner_id;

-- 4.How many of each type of pizza was delivered?
select pn.pizza_id , pn.pizza_name , 
count(co.order_id) as Pizza_count 
from customer_orders as co
join pizza_names as pn 
on co.pizza_id = pn.pizza_id
group by pn.pizza_name , pn.pizza_id;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, pn.pizza_name, COUNT(co.order_id) AS pizza_count
FROM customer_orders AS co
JOIN pizza_names AS pn ON co.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name, co.customer_id
order by customer_id;

-- 6.What was the maximum number of pizzas delivered in a single order?
with cte as
			(
				SELECT COUNT(pizza_id) AS order_count, order_id
				FROM customer_orders
				GROUP BY order_id
			)
SELECT order_id  , MAX(order_count) AS number_of_orders
FROM cte
GROUP BY order_id
order by number_of_orders DESC
limit 1;


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
SUM(CASE WHEN (exclusions IS NOT NULL OR extras IS NOT NULL) THEN 1 ELSE 0
    END) AS pizzas_with_atleast_one_change,
    SUM(CASE WHEN (exclusions IS NULL AND extras IS NULL) THEN 1 ELSE 0
    END) AS pizzas_with_no_change
FROM
    customer_orders_temp
GROUP BY customer_id;

-- 8.How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS pizzas_with_both_exclusions_and_extras
FROM customer_orders_temp
WHERE exclusions IS NOT NULL AND extras IS NOT NULL;
        
-- 9.What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  extract(hour from order_time) AS Hour_of_the_day,
  COUNT(order_id) AS pizza_ordered,
  CONCAT(
    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER() * 100, 2),
    '%'
  ) AS Volume_of_pizza_ordered
FROM customer_orders
GROUP BY extract(hour from order_time)
ORDER BY extract(hour from order_time);

-- 10.What was the volume of orders for each day of the week?

SELECT 
  dayname(order_time) AS Day_of_the_week, 
  COUNT(order_id), 
  CONCAT(ROUND(COUNT(order_id)/ SUM(COUNT(order_id)) OVER() * 100,2
    ),"%") AS volume_of_pizzas_ordered 
FROM 
  customer_orders_temp 
GROUP BY 1, 
  dayofweek(order_time) 
ORDER BY 
  dayofweek(order_time);
  
  
-- B. Runner and Customer Experience

-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date) AS week , 
COUNT(runner_id) AS runner_count
FROM runners
GROUP BY week;

-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id,
AVG(MINUTE(TIMEDIFF(r.pickup_time, c.order_time))) AS time_mins
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
GROUP BY r.runner_id;
-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?


-- 4.What was the average distance travelled for each customer?
select co.customer_id  , AVG(ro.distance) as Distance_travelled
from customer_orders as co
join runner_orders as ro
on co.order_id = ro.order_id
group by co.customer_id;

-- 5.What was the difference between the longest and shortest delivery times for all orders?
SELECT
    MAX(duration_mins) - MIN(duration_mins) AS delivery_time_diff
FROM runner_orders_post;
-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    runner_id, 
    AVG(distance_km) AS avg_distance_km,
    AVG(duration_mins) AS avg_duration_mins,
    AVG(distance_km / duration_mins) AS avg_speed
FROM runner_orders_post
GROUP BY runner_id;



-- 7. What is the successful delivery percentage for each runner?
WITH cancellation_counter AS (
SELECT runner_id,CASE WHEN cancellation IS NULL OR cancellation = 'NaN' THEN 1
	ELSE 0
    END AS no_cancellation_count,CASE WHEN cancellation IS NOT NULL OR cancellation != 'NaN' THEN 1
	ELSE 0
    END AS cancellation_count
FROM runner_orders_post
)
SELECT runner_id, SUM(no_cancellation_count) / (SUM(no_cancellation_count) 
+ SUM(cancellation_count))*100 AS delivery_success_percentage
FROM cancellation_counter
GROUP BY runner_id;


