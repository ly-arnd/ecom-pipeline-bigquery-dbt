{{
    config(
        materialized="table",
        cluster_by = ["order_id", "seller_id"]
    )
}}

SELECT
    *,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_order_items") }}