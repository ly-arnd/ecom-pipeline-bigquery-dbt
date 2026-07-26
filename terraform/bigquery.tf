locals {
  dbt_source = yamldecode(file("${path.module}/../dbt/ecommerce_datahub/models/sources.yml"))

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

  delete_contents_on_destroy = terraform.workspace != "prod"
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

  schema = fileexists("${path.module}/external-table-schemas/${terraform.workspace}/external-table-schemas/${each.key}.json") ? file("${path.module}/external-table-schemas/${terraform.workspace}/external-table-schemas/${each.key}.json") : null

  external_data_configuration {
    source_uris   = [each.value.location]
    source_format = "CSV"

    ignore_unknown_values = true

    csv_options {
      skip_leading_rows     = 1
      field_delimiter       = ","
      quote                 = "\""
      allow_quoted_newlines = true
      allow_jagged_rows     = false
    }

    autodetect =  fileexists("${path.module}/external-table-schemas/${terraform.workspace}/${each.key}.json") ? false : true
  }
}
