with order_sum as (
    select op.order_id, sum(op.payment_value) as order_value
    from order_payments op
    join orders o on o.order_id = op.order_id
    where o.order_status = 'delivered'
    group by op.order_id
),
raw_orders_by_state as (
    select os.order_id, os.order_value, c.customer_state
    from order_sum os
    join orders o on o.order_id = os.order_id
    join customers c on c.customer_id = o.customer_id
)

select * from raw_orders_by_state
where customer_state in ('RJ', 'SP', 'PB', 'MG');
