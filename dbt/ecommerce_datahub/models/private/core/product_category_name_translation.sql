{{
    config(
        materialized="table",
        cluster_by = ["product_category_name"]
    )
}}

SELECT
    TRIM(LOWER(product_category_name)) AS product_category_name,
    TRIM(LOWER(product_category_name_english)) AS product_category_name_english,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "product_category_name_translation") }}