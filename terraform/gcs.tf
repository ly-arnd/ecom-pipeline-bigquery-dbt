locals {
  repo_root = abspath("${path.module}/..")
  dataset_path = "${local.repo_root}/${var.dataset_subpath}"

  data_files = fileset(local.dataset_path, "**/*.csv")

  content_types = {
    csv  = "text/csv"
    json = "application/json"
    txt  = "text/plain"
  }
}

resource "google_storage_bucket" "data_bucket" {
  name     = var.gcs_bucket_name_prefix
  project  = var.project_id
  location = var.region

  storage_class               = "STANDARD"
  force_destroy               = var.force_destroy_bucket
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      with_state = "ANY"
      age        = var.data_retention_days
    }
  }
}

# Fail fast if the dataset directory is missing or empty.
check "dataset_present" {
  assert {
    condition     = length(local.data_files) > 0
    error_message = "No CSV files found under ${local.dataset_path}. Check var.dataset_subpath."
  }
}

# Dataset upload
resource "google_storage_bucket_object" "data_files" {
  for_each = local.data_files

  name   = each.key
  bucket = google_storage_bucket.data_bucket.name
  source = "${local.dataset_path}/${each.key}"

  # Specify content type based on file extension, defaulting to binary if unknown
  content_type = lookup(
    local.content_types,
    lower(try(reverse(split(".", each.key))[0], "")),
    "application/octet-stream",
  )

  # Triggers re-upload when the local file content changes
  metadata = {
    md5        = filemd5("${local.dataset_path}/${each.key}")
    managed_by = "terraform"
  }
}

output "uploaded_files" {
  description = "Files uploaded to the staging bucket."
  value       = sort(tolist(local.data_files))
}