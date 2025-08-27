
--Average Order Value by City (Delivered Only)**
--Output: city, avg_order_value, delivered_orders_count. Order by `avg_order_value` desc. Use `HAVING` to keep cities with at least 2 delivered orders.


select c.city,
AVG(oi.quantity*oi.unit_price) as avg_order_value,
count(distinct o.order_id) as delivered_orders_count
from orders o
join customers c on o.customer_id=c.customer_id 
join order_items oi on oi.order_id = o.order_id 
where o.status='delivered'
group by c.city 
having count(o.order_id)>1
order by avg_order_value desc


--Category Mix per Customer**
--For each customer, list categories purchased and the **count of distinct orders** per category. Order by customer and count desc.

select o.customer_id,
p.category, count(distinct o.order_id) as count_of_distinct_orders
from orders o
join order_items oi on o.order_id=oi.order_id
join products p on p.product_id=oi.product_id
group by o.customer_id,p.category 
order by o.customer_id, count_of_distinct_orders desc


-- Set Ops: Overlapping Customers**
--  Split customers into two sets: those who bought `Electronics` and those who bought `Fitness`. Show:
--      `UNION` of both sets,
--      `INTERSECT` (bought both),
--      `EXCEPT` (bought Electronics but not Fitness).

select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Electronics'

select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Electronics'

--Union
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Electronics'
)
union 
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Fitness'
);


--INTERSECT
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Electronics'
)
intersect 
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Fitness'
);

--EXCEPT
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Electronics'
)
except 
(
select o.customer_id
from orders o
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id = oi.product_id 
where p.category='Fitness'
);





