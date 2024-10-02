/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id) AS total_num_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities. 

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_orders DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, sum(order_details.quantity) as total_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
    group by pizza_types.category order by total_orders desc;



-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time), SUM(order_details.quantity)
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.order_time)
ORDER BY HOUR(orders.order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category,
    COUNT(name) AS distribution
FROM
    pizza_types
GROUP BY category
ORDER BY distribution;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    round(AVG(qty),2)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS qty
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS avg_orders_per_day;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    CONCAT(ROUND((SUM(order_details.quantity * pizzas.price) * 100) / (SELECT 
                            SUM(order_details.quantity * pizzas.price)
                        FROM
                            order_details
                                JOIN
                            pizzas ON order_details.pizza_id = pizzas.pizza_id),
                    2),
            ' %') AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue from (select 
    orders.order_date,
    round(SUM(order_details.quantity * pizzas.price),2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from (select category, name, revenue, rank()  over(partition by category order by revenue desc) as earning_rank from
(SELECT 
    pizza_types.category, pizza_types.name,
    round(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id group by pizza_types.name, pizza_types.category) as a)as b where earning_rank <=3;
