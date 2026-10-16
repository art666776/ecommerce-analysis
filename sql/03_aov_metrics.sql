with
-- Сумма каждого заказа 
order_sum as (
    select op.order_id, sum(op.payment_value) as order_value
    from order_payments op
    join orders o on o.order_id = op.order_id
    where o.order_status = 'delivered'
    group by op.order_id
),

-- Общий AOV
order_aov as (
    select avg(order_value) as aov, count(*) as orders_count
    from order_sum
),

-- AOV по категориям 
category_aov as (
    select
        ct.product_category_name_english,
        avg(oi.price + oi.freight_value) as category_value,
        count(*) as items_count
    from products p
    join order_items oi on oi.product_id = p.product_id
    join orders o on o.order_id = oi.order_id
    join category_translation ct on ct.product_category_name = p.product_category_name
    where o.order_status = 'delivered'
    group by ct.product_category_name_english
    order by category_value desc
),

-- AOV по штатам клиента 
state_aov as (
    select
        c.customer_state,
        avg(os.order_value) as state_value,
        count(*) as orders_count
    from customers c
    join orders o on c.customer_id = o.customer_id
    join order_sum os on os.order_id = o.order_id
    group by c.customer_state
    order by state_value desc
)


-- Раскомментируйте ОДИН из следующих SELECT
select * from order_aov;
-- select * from category_aov;
-- select * from state_aov;
