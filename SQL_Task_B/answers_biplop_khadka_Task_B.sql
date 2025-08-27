
-- Create View: `vw_recent_orders_30d`**
-- View of orders placed in the **last 30 days** from `CURRENT_DATE`, excluding `cancelled`.
-- Columns: order_id, customer_id, order_date, status, order_total (sum of items).

create view vw_recent_orders_30d as
select o.order_id,o.customer_id,o.order_date,o.status,sum(oi.quantity*oi.unit_price) as order_total
from orders o
join order_items oi on oi.order_id=o.order_id
where o.status!='cancelled'
and AGE(DATE(NOW()),o.order_date)<=interval '30 days'
group by o.order_id,o.customer_id,o.order_date,o.status;

select * from vw_recent_orders_30d;


--Products Never Ordered**
--Using a subquery, list products that **never** appear in `order_items`.

select * from products p 
where not exists(
	select * from order_items oi 
	where oi.product_id=p.product_id
)



--Top Category by City**
--For each `city`, find the **single category** with the highest total revenue. Use an inner subquery or a view plus a filter on rank.

create or replace view vw_city_category_rank as 
select c.city,p.category, sum(oi.quantity*oi.unit_price) as total_revenue,
RANK() over (partition by c.city order by sum(oi.quantity*oi.unit_price) DESC) as rnk
from customers c
join orders o on c.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
join products p on p.product_id=oi.product_id
group by c.city,p.category;



select * from vw_city_category_rank
where rnk=1;


--Customers Without Delivered Orders**
--Using `NOT EXISTS`, list customers who have **no orders** with status `delivered`.


select * from customers c
where not exists ( 
	select * from orders o where o.customer_id=c.customer_id 
	and o.status='delevered'
)
