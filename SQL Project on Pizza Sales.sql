CREATE DATABASE Pizza;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) 
);

create table orders_details(
orders_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(orders_details_id) 
);

select * from orders_details;



-- Retrieve the total number of orders placed.

select count(order_id) as Total_orders from orders;



-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;



-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.orders_details_id) AS Order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_count DESC;



-- List the top 5 most ordered pizza types 
-- along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;



-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Order_count
FROM
    orders
GROUP BY hour
ORDER BY Order_count DESC;



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Quantity
FROM
    pizza_types
GROUP BY category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Total_quantity), 0) as avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS Total_quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_Quantity;
    
    
    
    -- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    (SUM(orders_details.quantity * pizzas.price) / (SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id)) * 100 as Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;



-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(orders_details.quantity * pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id=pizzas.pizza_id
join orders on orders_details.order_id=orders.order_id
group by orders.order_date) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name , revenue from
(select category, name , revenue,
rank() over (partition by category order by revenue desc) as rn
from 
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity)* pizzas.price) as revenue
from pizzas join pizza_types on
pizzas.pizza_type_id=pizza_types.pizza_type_id
join orders_details on
orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name)as a) as b
where rn <= 3;
    
    
