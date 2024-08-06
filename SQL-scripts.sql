/* © 2024 TUSHAR SONI. All rights reserved. 
https://github.com/Tusharsoni69/SQL-Pizza-Sales-Project
*/

SELECT * FROM pizza_sales;

/*-------------------------------------------------------------------------------------------------------------------------*/
-- 1)the total number of orders placed.

SELECT COUNT(order_id) as total_orders
from orders;


-- 2)Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- 3)Identify the highest-priced pizza.
SELECT 
    pizza_types.name, max(pizzas.price) AS MAX_PRICE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id

GROUP BY  pizza_types.name, pizzas.price
ORDER BY pizzas.price DESC
LIMIT 1;



-- 4)Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS ORDER_COUNT
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY ORDER_COUNT DESC;



-- 5)List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS ORDER_QUANTITY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY ORDER_QUANTITY DESC
LIMIT 5;

-- 6)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS ORDER_QUANTITY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY ORDER_QUANTITY DESC;



-- 7)Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(ORDER_TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT
FROM
    orders
GROUP BY HOUR(ORDER_TIME);


-- 8)Join relevant tables to find the category-wise distribution of pizzas.

SELECT pizza_types.category ,count(name)
from pizza_types
group by category;



-- 9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(QUANTITY), 0) AS AVG_PIZZA_ORDER
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS ORDER_QUANTIY;



-- 10)Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY REVENUE DESC
LIMIT 3;



-- 11)Calculate the percentage contribution of each pizza type to total revenue.
 SELECT 
    pt.category,
    ROUND((((SUM(p.price * od.quantity) / (SELECT 
                    SUM(p.price * od.quantity)
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id)) * 100)),
            2) AS PERCENTAGE
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;
    
    
 
-- 12)Analyze the cumulative revenue generated over time.

with commulative_table as (
SELECT o.order_date, round(sum(od.quantity*p.price),2) as revenue FROM order_details od 
join pizzas p 
on p.pizza_id=od.pizza_id
join orders o
on o.order_id=od.order_id
group by o.order_date 
order by o.order_date)
select *, round(sum(revenue) over(order by order_date),2) as cumm_revenue from commulative_table ;


-- 13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name , revenue, 
rank() over(partition by category order by revenue desc) as rn from 
(select pizza_types.name, pizza_types.category,  
round(sum(pizzas.price*order_details.quantity),2) as revenue from pizzas join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name, pizza_types.category 
order by revenue desc) as a
)
select * from cte
where rn<=3;
/*-------------------------------------------------------------------------------------------------------------------------*/