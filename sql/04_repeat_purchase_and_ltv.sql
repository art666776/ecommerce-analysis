with

-- Клиенты с 2+ delivered-заказами
clients_2_orders as (
    select c.customer_unique_id, count(*) as order_cnt
    from customers c
    join orders o on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
    having count(*) > 1
),

-- Суммарные траты каждого клиента 
ltv as (
    select c.customer_unique_id, sum(op.payment_value) as customer_ltv
    from order_payments op
    join orders o on o.order_id = op.order_id
    join customers c on c.customer_id = o.customer_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
    order by customer_ltv desc
),

-- LTV = средняя сумма трат на клиента
avg_ltv as (
    select avg(customer_ltv) as ltv
    from ltv
),

-- Repeat Purchase Rate = доля клиентов с 2+ заказами от всех уникальных клиентов
rpr as (
    select
        cast(count(cto.customer_unique_id) as numeric) /
        (select count(distinct customer_unique_id)
         from customers c
         join orders o on o.customer_id = c.customer_id
         where o.order_status = 'delivered') * 100 as rpr
    from clients_2_orders cto
)


-- Раскомментируйте ОДИН из следующих SELECT

select * from avg_ltv;
-- select * from rpr;
