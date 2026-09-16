with order_sum as (
    select op.order_id, sum(op.payment_value) as order_value
    from order_payments op
    join orders o on o.order_id = op.order_id
    where o.order_status = 'delivered'
    group by op.order_id
),
order_aov as (
    select avg(order_value) as value from order_sum
),
clients_2_orders as (
    select c.customer_unique_id, count(*) as order_cnt
    from customers c
    join orders o on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
    having count(*) > 1
),
total_customers as (
    select count(distinct c.customer_unique_id) as cnt
    from customers c
    join orders o on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
),
rpr as (
    select
        cast(count(cto.customer_unique_id) as numeric) / (select cnt from total_customers) * 100 as value
    from clients_2_orders cto
),
customer_ltv as (
    select c.customer_unique_id, sum(op.payment_value) as customer_ltv
    from order_payments op
    join orders o on o.order_id = op.order_id
    join customers c on c.customer_id = o.customer_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
),
avg_ltv as (
    select avg(customer_ltv) as value from customer_ltv
)
select 'AOV' as metric_name, value from order_aov
union all
select 'Repeat Purchase Rate (%)', value from rpr
union all
select 'LTV', value from avg_ltv;
