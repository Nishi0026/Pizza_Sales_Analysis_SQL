-- Retrieve total no. of orders placed

SELECT 
    COUNT(*) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_sales
FROM
    pizzas AS p
        JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id;
    
    
 -- Identify the highest priced pizza
 
SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered

SELECT 
    p.size, COUNT(o.order_id)
FROM
    pizzas AS p
        JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY COUNT(o.order_id) DESC;


-- list the top 5 most ordered pizza types along with their quantities

SELECT 
    pt.name, SUM(o.quantity)
FROM
    orders_details AS o
        JOIN
    pizzas AS p ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(o.quantity) DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    pt.category, SUM(o.quantity) as quantity
FROM
    orders_details AS o
        JOIN
    pizzas AS p ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY SUM(o.quantity) DESC;


-- Determine the distribution of order by hour of the day

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC;

-- join relevant tables to find the category wise distribution of pizzas

SELECT 
    category, COUNT(category)
FROM
    pizza_types
GROUP BY category
ORDER BY COUNT(category) DESC;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

with order_quantity as 
     (select o.order_date, sum(od.quantity) as quantity
	  from orders as o
	  join orders_details as od on o.order_id = od.order_id 
	   group by order_date)
select round(avg(quantity),0) from order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
 
 SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    orders_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
 
 -- Calculate the percentage contribution of each pizza type to total revenue.
 

 SELECT 
    pt.category,
    (SUM(od.quantity * p.price) / (SELECT 
            ROUND(SUM(p.price * o.quantity), 2) AS total_sales
        FROM
            pizzas AS p
                JOIN
            orders_details AS o ON p.pizza_id = o.pizza_id)) * 100 AS revenue_percentage
FROM
    orders_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue_percentage;


-- Analyse the cumulative revenue generated over time

with revenue_per_date as (
     select o.order_date as o_date , sum(od.quantity * p.price) as revenue
     from orders as o 
     join orders_details as od on o.order_id = od.order_id
     join pizzas as p on od.pizza_id = p.pizza_id
     group by order_date
     order by revenue
)

select o_date, sum(revenue) over(order by o_date) as Cum_revenue
from revenue_per_date;


-- Determine the top 3 most ordered pizzas types based on revenue for each pizza category

with cat_revenue as (
select pt.name, pt.category, sum(o.quantity * p.price) as revenue,
row_number() over(partition by pt.category order by sum(o.quantity * p.price) desc) as row_no
from orders_details as o join pizzas as p
on o.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category, pt.name
)

select * from cat_revenue 
where row_no <= 3;





