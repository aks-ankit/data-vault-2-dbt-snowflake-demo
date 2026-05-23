{{
    config(
        materialized='table'
    )
}}
SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_DATE,
    TRANSACTION_DATE,
    TRANSACTION_NUMBER,
    AMOUNT,
    TYPE
FROM {{ source('tpch_sample_2', 'raw_transactions') }}
where
order_date_airflow >= DATEADD(day, -30, TO_DATE('{{ var('logical_date') }}'))
and order_date_airflow <= TO_DATE('{{ var('logical_date') }}')