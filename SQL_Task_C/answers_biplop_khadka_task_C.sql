--Scalar Function: `fn_customer_lifetime_value(customer_id)`**
--Return total **paid** amount for the customer's delivered/shipped/placed (non-cancelled) orders.


create or replace function fn_customer_lifetime_value(customer_id INT)
returns INT
language plpgsql
as $$
declare
    total_amount INT;
begin
    select SUM(p.amount) 
    into total_amount
    from payments p
    join orders o ON o.order_id = p.order_id
    where o.customer_id = fn_customer_lifetime_value.customer_id
    and o.status != 'cancelled';

    return total_amount;
end;
$$;


select fn_customer_lifetime_value(3)

--**Table Function: `fn_recent_orders(p_days INT)`**
--Return `order_id, customer_id, order_date, status, order_total` for orders in the last `p_days` days.

create or replace function fn_recent_orders(p_days INT)
returns table (
	order_id int,
	customer_id int,
	order_date timestamp,
	status varchar(20),
	order_total Numeric(10,2)
)
language plpgsql
as $$ 
begin
	return QUERY
	select o.order_id,o.customer_id,o.order_date,o.status, sum(oi.quantity*oi.unit_price) as order_total
	from orders o
	join order_items oi on o.order_id=oi.order_id
	where (CURRENT_DATE - o.order_date::date)=p_days
	group by o.order_id,o.customer_id,o.order_date,o.status;
end;
$$;


SELECT * FROM fn_recent_orders(174); 


--Utility Function: `fn_title_case_city(text)`**
--Return city name with first letter of each word capitalized (hint: split/upper/lower or use `initcap()` in PostgreSQL).
	
create or replace function fn_title_case_city(city_name text)
returns text
language plpgsql
as $$
begin
return initcap(city_name);
end;
$$;


select fn_title_case_city('kathmandu');