with
order_status_breakdown as (
    select order_status, count(order_status) as cnt
    from orders
    group by order_status
    order by cnt desc
),

date_range as (
    select
        min(order_purchase_timestamp) as min_date,
        max(order_purchase_timestamp) as max_date
    from orders
),

customer_id_comparison as (
    select
        count(distinct customer_id) as cnt_customer_id,
        count(distinct customer_unique_id) as cnt_customer_unique_id
    from customers
),

orders_per_customer as (
    select c.customer_unique_id, count(o.order_id) as order_cnt
    from orders o
    join customers c on o.customer_id = c.customer_id
    group by c.customer_unique_id
),
order_count_category as (
    select
        customer_unique_id,
        case
            when order_cnt = 1 then '1'
            when order_cnt = 2 then '2'
            else '3+'
        end as cnt_category
    from orders_per_customer
),
order_count_distribution as (
    select cnt_category, count(*) as customers_cnt
    from order_count_category
    group by cnt_category
),

duplicate_order_ids as (
    select count(*) as cnt
    from (
        select order_id
        from orders
        group by order_id
        having count(order_id) > 1
    ) as dup
),
data_quality_checks as (
    select 'duplicate_order_id' as check_name, cnt from duplicate_order_ids
    union all
    select 'null_customer_id', count(*) from orders where customer_id is null
    union all
    select 'null_order_purchase_timestamp', count(*) from orders where order_purchase_timestamp is null
)

-- Раскомментируйте ОДИН из следующих SELECT, чтобы посмотреть результат

select * from order_status_breakdown;
-- select * from date_range;
-- select * from customer_id_comparison;
-- select * from order_count_distribution;
-- select * from data_quality_checks;
