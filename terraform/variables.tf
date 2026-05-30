# Load configuration from YAML file
locals {
  config_base = yamldecode(file("${path.module}/config/qa.yaml"))

  # Override YAML values with environment variables if set
  config = merge(
    local.config_base,
    {
      project = {
        id     = var.project_id != "" ? var.project_id : local.config_base.project.id
        region = var.region != "" ? var.region : local.config_base.project.region
      }
    }
  )
}

##### PROJECT VARIABLES #####

variable "project_id" {
  description = "The Google Cloud project ID where resources will be created."
  type        = string
  default     = ""  # Reads from TF_VAR_project_id env var, falls back to config.yaml
}

variable "region" {
  description = "The GCP region for Cloud Build resources."
  type        = string
  default     = ""  # Reads from TF_VAR_region env var, falls back to config.yaml
}