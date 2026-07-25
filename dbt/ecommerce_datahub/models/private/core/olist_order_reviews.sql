{{
    config(
        materialized="table",
        partition_by = {
            "field": "review_creation_date",
            "data_type": "timestamp",
            "granularity": "day"
        },
        cluster_by = ["order_id"]
    )
}}

SELECT
    *,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_order_reviews") }}