locals {
  datasets = {
    public = {
      description = "Public dataset for open data and shared resources."
    }

    private = {
      description = "Private dataset for internal data."

      # TODO set access
      # access = [
      #   {
      #     role          = "OWNER"
      #     user_by_email = google_service_account.bqowner.email
      #   }
      # ]
    }
  }
}


resource "google_bigquery_dataset" "dataset" {
  for_each = local.datasets

  dataset_id                  = each.key
  description                 = each.value.description
  location                    = "EU"
  default_table_expiration_ms = 3600000 # 1 hour
}