{{
    config(
        materialized="table"
    )
}}

SELECT
    *  EXCEPT (product_name_lenght, product_description_lenght),
    product_name_lenght AS product_name_length,
    product_description_lenght AS product_description_length,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_products") }}