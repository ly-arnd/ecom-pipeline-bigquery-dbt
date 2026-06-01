locals {
  dbt_source = yamldecode(file("${path.module}/../dbt/models/sources.yml"))

  ecommerce_source = one([
    for s in local.dbt_source.sources : s
    if s.name == local.config.bigquery.dbt_seeds.dbt_source_name
  ])

  table_location_pairs = {
    for t in local.ecommerce_source.tables :
    t.name => {
      location = replace(t.external.location, "{{ env_var('GCP_BUCKET_NAME') }}", var.bucket_name)
    }
  }
}


resource "google_bigquery_dataset" "dataset" {
  for_each = local.config.bigquery.datasets

  dataset_id                  = each.key
  description                 = each.value.description
  location                    = each.value.location
  default_table_expiration_ms = each.value.default_table_expiration_ms
}

# terraform/main.tf
resource "google_bigquery_table" "landing_external_table" {
  depends_on = [
    google_bigquery_dataset.dataset["landing"],
    google_storage_bucket_object.data_files
  ]

  for_each = local.table_location_pairs

  dataset_id = google_bigquery_dataset.dataset["landing"].dataset_id
  table_id   = each.key

  deletion_protection = terraform.workspace == "prod"

  external_data_configuration {
    source_uris = [each.value.location]
    source_format = "CSV"

    csv_options {
      skip_leading_rows = 1
      field_delimiter   = ","
      quote             = "\""
    }

    autodetect = true
  }
}
