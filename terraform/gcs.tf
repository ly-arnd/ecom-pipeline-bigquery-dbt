locals {
  repo_root = abspath("${path.module}/..")
  dataset_path = "${local.repo_root}/${local.config.gcs.dataset_subpath}"
  data_files = fileset(local.dataset_path, "**/*.csv")
}

resource "google_storage_bucket" "data_bucket" {
  name     = local.config.gcs.bucket.name_prefix
  project  = local.config.project.id
  location = local.config.project.region

  storage_class               = local.config.gcs.bucket.storage_class
  force_destroy               = local.config.gcs.bucket.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = local.config.gcs.bucket.public_access_prevention

  versioning {
    enabled = local.config.gcs.bucket.versioning_enabled
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      with_state = "ANY"
      age        = local.config.gcs.data_retention_days
    }
  }
}

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
    local.config.gcs.content_types,
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