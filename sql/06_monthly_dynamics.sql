with order_sum as (
    select op.order_id, sum(op.payment_value) as order_value
    from order_payments op
    join orders o on o.order_id = op.order_id
    where o.order_status = 'delivered'
    group by op.order_id
),
monthly_dynamics as (
    select
        date_trunc('month', o.order_purchase_timestamp) as order_month,
        count(*) as orders_count,
        sum(os.order_value) as total_revenue
    from order_sum os
    join orders o on o.order_id = os.order_id
    group by date_trunc('month', o.order_purchase_timestamp)
    order by order_month
)
select
    order_month,
    orders_count,
    total_revenue,
    avg(total_revenue) over (
        order by order_month
        rows between 2 preceding and current row
    ) as revenue_3m_moving_avg
from monthly_dynamics;
