{{
    config(
        materialized="table",
        partition_by = {
            "field": "order_purchase_timestamp",
            "data_type": "timestamp",
            "granularity": "day"
        },
        cluster_by = ["customer_id", "order_status"]
    )
}}

SELECT
    *,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_orders") }}