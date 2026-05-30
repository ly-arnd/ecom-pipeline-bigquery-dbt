##### PROJECT VARIABLES #####

variable "project_id" {
  description = "The Google Cloud project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for Cloud Build resources."
  type        = string
}

##### GCS VARIABLES ######

variable "gcs_bucket_name_prefix" {
  description = "Prefix for the GCS bucket name. Project ID will be appended for uniqueness."
  type        = string
  default     = "ecommerce-data-staging-bucket"
}

variable "dataset_subpath" {
  description = "Path to the dataset directory, relative to the repository root."
  type        = string
  default     = "dbt/seeds"
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to destroy the bucket even if it contains objects. Set to false in prod."
  type        = bool
  default     = true
}

variable "data_retention_days" {
  description = "Days to retain objects in the staging bucket before deletion."
  type        = number
  default     = 2
}