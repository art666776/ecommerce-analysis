with order_sum as (
    select op.order_id, sum(op.payment_value) as order_value
    from order_payments op
    join orders o on o.order_id = op.order_id
    where o.order_status = 'delivered'
    group by op.order_id
),
state_full_metrics as (
    select
        c.customer_state,
        avg(os.order_value) as aov,
        sum(os.order_value) as total_revenue,
        count(*) as orders_count
    from customers c
    join orders o on c.customer_id = o.customer_id
    join order_sum os on os.order_id = o.order_id
    group by c.customer_state
    order by total_revenue desc
)
select * from state_full_metrics;
