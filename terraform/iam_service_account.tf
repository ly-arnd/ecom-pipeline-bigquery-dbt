resource "google_service_account" "airflow_service_account" {
  project      = local.config.project.id
  account_id   = local.config.iam_service_account.airflow.service_account_id
  display_name = local.config.iam_service_account.airflow.service_account_display_name
  description  = "Service Account for Airflow to interact with Google Cloud resources."
}

resource "google_project_iam_member" "airflow_iam_bindings" {
  for_each = toset(local.config.iam_service_account.airflow.required_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.airflow_service_account.email}"
}

resource "google_service_account_key" "airflow_key" {
  service_account_id = google_service_account.airflow_service_account.name
}

output "airflow_service_account_key" {
  description = "The airflow service account email used by airflow."
  value       = google_service_account_key.airflow_key.private_key
  sensitive   = true
}