with category_full_metrics as (
    select
        ct.product_category_name_english,
        avg(oi.price + oi.freight_value) as avg_item_value,
        sum(oi.price + oi.freight_value) as total_revenue,
        count(*) as items_count
    from products p
    join order_items oi on oi.product_id = p.product_id
    join orders o on o.order_id = oi.order_id
    join category_translation ct on ct.product_category_name = p.product_category_name
    where o.order_status = 'delivered'
    group by ct.product_category_name_english
    order by total_revenue desc
)
select * from category_full_metrics;
