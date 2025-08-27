
--sp_apply_category_discount(p_category TEXT, p_percent NUMERIC)`**
--Reduce `unit_price` of **active** products in a category by `p_percent` (e.g., 10 = 10%). Prevent negative or zero prices using a `CHECK` at update time.


create or replace procedure sp_apply_category_discount(p_category TEXT, p_percent NUMERIC)
language plpgsql
as $$ 
begin
	update products
	set unit_price=unit_price*(1-p_percent/100)
	where category=p_category
	and active=True;
end;
$$;

call sp_apply_category_discount('Electronics',10);
select * from products;

--`sp_cancel_order(p_order_id INT)`**
-- Set order `status` to `cancelled` **only if** it is not already `delivered`.
-- (Optional) Delete unpaid `payments` if any exist for that order (there shouldn’t be, but handle defensively).

create or replace procedure sp_cancel_order(p_order_id INT)
language plpgsql
as $$
begin
	update orders
	set status='cancelled'
	where order_id=p_order_id
	and status!='delivered';	
end;
$$;

call sp_cancel_order(3)

select * from orders


--`sp_reprice_stale_products(p_days INT, p_increase NUMERIC)`**
-- For products **not ordered** in the last `p_days`, increase `unit_price` by `p_increase` percent.

create or replace procedure sp_reprice_stale_products(p_days INT, p_increase NUMERIC)
language plpgsql
as $$
begin
	update products
	set unit_price = unit_price * (1 - p_increase / 100)
	where product_id not in (
		select distinct product_id
		 from order_items oi
		 join orders o on o.order_id =  oi.order_id
		 where o.order_date >= CURRENT_DATE - p_days
	);
end;
$$;

call sp_reprice_stale_products(10,5)

select * from products

