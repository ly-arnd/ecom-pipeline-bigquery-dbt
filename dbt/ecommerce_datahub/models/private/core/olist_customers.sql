{{
    config(
        materialized="table"
    )
}}

SELECT
    *  EXCEPT (customer_zip_code_prefix),
    LPAD(CAST(customer_zip_code_prefix AS STRING), 5, '0') AS customer_zip_code_prefix,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_customers") }}