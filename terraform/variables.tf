# Load configuration from YAML file
locals {
  environment = terraform.workspace
  config_base = yamldecode(file("${path.module}/config/${terraform.workspace}.yaml"))

  # Override YAML values with environment variables
  config = merge(
    local.config_base,
    {
      project = {
        id     = var.project_id
        region = var.region
      }
      gcs = merge(
        local.config_base.gcs,
        {
          bucket_name = var.bucket_name
        }
      )
    }
  )
}

check "gcp_project_config" {
  assert {
    condition     = length(local.config.project.id) > 0
    error_message = "GCP Project ID is not set. Export .env var TF_VAR_project_id or set it in ${path.module}/config/${terraform.workspace}.yaml."
  }

  assert {
    condition     = length(local.config.project.region) > 0
    error_message = "GCP Project region is not set. Export .env var TF_VAR_region or set it in ${path.module}/config/${terraform.workspace}.yaml."
  }

  assert {
    condition     = length(local.config.gcs.bucket_name) > 0
    error_message = "GCP Project region is not set. Export .env var TF_VAR_bucket_name or set it in ${path.module}/config/${terraform.workspace}.yaml."
  }
}


##### PROJECT VARIABLES #####

variable "project_id" {
  description = "The Google Cloud project ID where resources will be created."
  type        = string
  default     = "" # Reads from TF_VAR_project_id env var, falls back to config.yaml
}

variable "region" {
  description = "The GCP region for Cloud Build resources."
  type        = string
  default     = "" # Reads from TF_VAR_region env var, falls back to config.yaml
}

variable "bucket_name" {
  description = "The GCP bucket name for landing data."
  type        = string
  default     = "" # Reads from TF_VAR_bucket_name env var, falls back to config.yaml
}
