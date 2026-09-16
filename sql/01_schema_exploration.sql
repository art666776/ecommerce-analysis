-- =====================================================================
-- ЭТАП 1. Разведка схемы данных (Olist E-Commerce)
-- =====================================================================
-- Файл объединяет все разведочные запросы этапа как отдельные CTE.
-- Запросы независимы друг от друга (не строятся один на другом),
-- поэтому выполняются по одному: раскомментируйте нужный SELECT
-- в самом низу файла и выполните весь блок.
-- =====================================================================

with

-- ---------------------------------------------------------------------
-- 1. Распределение заказов по статусам
-- Нужно, чтобы решить, какие заказы включать в дальнейший анализ
-- (когорты/метрики строятся только на статусе 'delivered')
-- ---------------------------------------------------------------------
order_status_breakdown as (
    select order_status, count(order_status) as cnt
    from orders
    group by order_status
    order by cnt desc
),

-- ---------------------------------------------------------------------
-- 2. Период данных (min/max дата заказа)
-- Нужно для понимания горизонта данных и для когортного анализа
-- ---------------------------------------------------------------------
date_range as (
    select
        min(order_purchase_timestamp) as min_date,
        max(order_purchase_timestamp) as max_date
    from orders
),

-- ---------------------------------------------------------------------
-- 3. customer_id vs customer_unique_id
-- customer_id уникален на ЗАКАЗ, customer_unique_id — на КЛИЕНТА.
-- Разница между числами показывает, сколько заказов сделано
-- повторными клиентами.
-- ---------------------------------------------------------------------
customer_id_comparison as (
    select
        count(distinct customer_id) as cnt_customer_id,
        count(distinct customer_unique_id) as cnt_customer_unique_id
    from customers
),

-- ---------------------------------------------------------------------
-- 4. Распределение клиентов по количеству заказов (1 / 2 / 3+)
-- Показывает будущий уровень retention ещё до когортного анализа
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- 5. Проверка на дубликаты и NULL в ключевых полях
-- Все три подсчёта объединены через UNION ALL в один читаемый результат
-- (в отличие от исходной версии, где два CTE не выполнялись из-за
-- ленивого вычисления CTE в PostgreSQL)
-- ---------------------------------------------------------------------
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

-- =====================================================================
-- Раскомментируйте ОДИН из следующих SELECT, чтобы посмотреть результат
-- =====================================================================

select * from order_status_breakdown;
-- select * from date_range;
-- select * from customer_id_comparison;
-- select * from order_count_distribution;
-- select * from data_quality_checks;
