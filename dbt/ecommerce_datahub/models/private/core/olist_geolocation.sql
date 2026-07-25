{{
    config(
        materialized="table"
    )
}}

SELECT
    *  EXCEPT (geolocation_zip_code_prefix),
    CAST(geolocation_zip_code_prefix AS STRING) AS geolocation_zip_code_prefix,
    _file_name AS source_file_name
FROM {{ source("ecommerce-data-landing_gcs", "olist_geolocation") }}