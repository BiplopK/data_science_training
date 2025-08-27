
--Monthly Customer Rank by Spend
--For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
--Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month.
select TO_CHAR(order_date,'YYYY-MM') as month, customer_id, SUM(i.quantity * i.unit_price) as total_monthly_spend,
rank() over(partition by  TO_CHAR(order_date,'YYYY-MM')
order by SUM(quantity * unit_price) desc) as rank_in_month
from orders o
inner join order_items i on i.order_id=o.order_id 
group by TO_CHAR(order_date,'YYYY-MM'), o.customer_id
order by month, rank_in_month


--Share of Basket per Item**
--For each order, compute each item's **revenue share** in that order:
--item_revenue / order_total` using `SUM() OVER (PARTITION BY order_id)`.

select order_id,product_id,
quantity*unit_price as item_revenue,
sum(quantity*unit_price) over (partition by order_id) as order_total,
(quantity*unit_price) / sum(quantity*unit_price) over (partition by order_id) as revenue_share
from order_items



--Time Between Orders (per Customer)**
 --Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`.
select order_id, customer_id, order_date,
LAG(order_date) over (partition by customer_id) as previous_order,
extract(day from AGE(order_date,LAG(order_date)  over (partition by customer_id))) as days_since_previous_order
from orders;


 --Product Revenue Quartiles**
 --Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue.

with product_revenue as(
select p.product_id,p.product_name, sum(i.quantity*i.unit_price) as total_revenue
from products p
inner join order_items i on i.product_id = p.product_id 
group by p.product_id,p.product_name 
)
select product_id,product_name,total_revenue, NTILE(4) over (order  by total_revenue)  as revenue_quartile
from product_revenue;


 --First and Last Purchase Category per Customer**
 --For each customer, show the **first** and **most recent** product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`.

select distinct c.customer_id,c.full_name,c.city,
first_value(p.category) over(partition by c.customer_id order by o.order_date desc) as first_category,
last_value(p.category) over (partition by c.customer_id order by o.order_date desc rows between unbounded preceding and unbounded following) as last_category 
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id 

