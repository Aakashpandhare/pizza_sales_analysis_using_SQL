CREATE DATABASE Pizzahut;
USE Pizzahut ;

-- 1) Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;
    
-- 2) Calculate the total revenue generated from pizza sales:    
    
SELECT 
    ROUND(SUM(p.price * o.quantity), 1) AS Revenue
FROM
    pizzas p
    JOIN order_details o ON p.pizza_id = o.pizza_id;
    
-- 3) Identify the highest-priced pizza:  

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
    JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4) Identify the most common pizza size ordered:
  
    SELECT 
    p.size, COUNT(o.order_id) AS total_order
FROM
    pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
    JOIN orders o ON o.order_id = od.order_id
GROUP BY p.size
ORDER BY 2 DESC;

-- 5) List the top 5 most ordered pizza types along with their quantities:

SELECT 
    pt.name, SUM(od.quantity) AS total_order
FROM
    pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
    JOIN orders o ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 6) Find the category-wise distribution of pizzas:

SELECT category, COUNT(name) AS pizzas 
FROM pizza_types
GROUP BY 1 
ORDER BY 2 DESC;

-- 7) Determine the distribution of orders by hour of the day:

SELECT DISTINCT
    HOUR(time) AS hour, COUNT(order_id) AS total_order
FROM
    orders
GROUP BY 1;

-- 8) Group the orders by date and calculate the average number of pizzas ordered per day:

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT DISTINCT
        o.date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY 1) AS order_quantity;


-- 9) Determine the top 3 most ordered pizza types based on revenue:

SELECT 
    pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- 10) Calculate the percentage contribution of each pizza type to total revenue:

SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(p.price * o.quantity), 1) AS Revenue
                FROM
                    pizzas p
                    JOIN order_details o ON p.pizza_id = o.pizza_id)) * 100,
            2) AS percentage_revenue
FROM
    pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 11) Analyze the cumulative revenue generated over time:

WITH cte1 AS (
    SELECT 
        MONTH(o.date) AS month,
        ROUND(SUM(od.quantity * p.price), 2) AS revenue
    FROM
        pizzas p
        JOIN order_details od ON p.pizza_id = od.pizza_id
        JOIN orders o ON o.order_id = od.order_id
    GROUP BY 1
    ORDER BY 1 )
SELECT month, 
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM cte1;

-- 12) Determine the top 3 most ordered pizza types based on revenue for each pizza category:

USE pizzahut;

WITH cte1 AS (
    SELECT pt.category, pt.name, 
          ROUND(SUM(od.quantity * p.price),2) AS revenue 
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
    JOIN order_details od ON od.pizza_id = p.pizza_id 
    GROUP BY pt.category, pt.name
),
cte2 AS (
    SELECT category, name, revenue, 
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS r_number 
    FROM 
        cte1 
)
SELECT category, name, revenue 
FROM cte2 
WHERE r_number <= 3;


-- 13) Calculate the total quantity of each pizza category ordered:

SELECT pt.category, SUM(od.quantity) AS total_order
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 2 DESC;




