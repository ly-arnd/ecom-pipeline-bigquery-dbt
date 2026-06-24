{{
    config(
        materialized="table"
    )
}}

SELECT
    *
FROM {{ source("ecommerce-data-landing_gcs", "olist_customers") }}