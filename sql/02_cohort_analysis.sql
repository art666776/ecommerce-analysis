-- =====================================================================
-- ЭТАП 2. Когортный анализ retention
-- =====================================================================
-- Результат — "длинный" формат для дальнейшей обработки в Python
-- (pivot, перевод в проценты, heatmap): notebooks/02_cohort_analysis.ipynb
-- =====================================================================

with

-- 1. Когорта каждого клиента = месяц его первого delivered-заказа
first_order as (
    select
        c.customer_unique_id,
        date_trunc('month', min(o.order_purchase_timestamp)) as cohort_month
    from orders o
    join customers c on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
),

-- 2. Все заказы клиента с привязкой к его когорте
all_orders as (
    select
        c.customer_unique_id,
        date_trunc('month', o.order_purchase_timestamp) as order_month,
        fo.cohort_month
    from orders o
    join customers c on o.customer_id = c.customer_id
    join first_order fo on fo.customer_unique_id = c.customer_unique_id
    where o.order_status = 'delivered'
),

-- 3. Номер месяца жизни когорты (0, 1, 2, ...) для каждого заказа
month_diff as (
    select
        customer_unique_id,
        order_month,
        cohort_month,
        extract(month from order_month) - extract(month from cohort_month) +
        (extract(year from order_month) - extract(year from cohort_month)) * 12 as month_number
    from all_orders
),

-- 4. Финальная агрегация: сколько уникальных клиентов в каждой ячейке
cohort_table as (
    select cohort_month, month_number, count(distinct customer_unique_id) as customer_count
    from month_diff
    group by cohort_month, month_number
)

select * from cohort_table
order by cohort_month, month_number;
