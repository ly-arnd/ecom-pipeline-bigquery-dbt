# Data Platform Infrastructure

Terraform resource folder used to provision and manage Google Cloud Platform (GCP) resources required by the [ecommerce_datahub](../dbt/ecommerce_datahub).

## Overview

This folder manages the following resources:

- Google Cloud Storage (GCS) buckets
- Service Accounts
- IAM roles and permissions
- BigQuery External Tables
- Upload of dbt sourced files to GCS

The infrastructure is fully environment-driven through YAML configuration files and supports multiple environments using Terraform workspaces.

---

## Architecture

The deployment process is as follows:

1. Terraform loads the configuration associated with the active workspace.
2. GCS buckets are created or updated.
3. Service Accounts are provisioned.
4. IAM permissions are assigned.
5. dbt sourced files are uploaded to GCS.
6. BigQuery External Tables are created and configured to read data directly from GCS. Schema is inferred from if no schema is provided in the [configuration folder](external-table-schemas).

---

## Prerequisites

### Required Tools

- Terraform >= 1.14.6
- Google Cloud SDK (`gcloud`)
- Appropriate GCP permissions

### Google cloud platform authentication

Using Application Default Credentials:

```bash
# Authenticate with your Google Cloud account
gcloud auth application-default login

# Check the current configuration
gcloud config list
```

---

## Deployment

For automated deployments:
```bash
cd terraform
set -a && source ../.env/dev.env && set +a
terraform init
terraform workspace new dev
terraform workspace select dev
terraform apply -auto-approve
terraform output -raw airflow_service_account_key > /tmp/key_b64.txt && base64 -d /tmp/key_b64.txt > ../keys/airflow-service-account-key.json 
```

---

## Configuration Management

Environment-specific configuration is stored under the `config/` directory.

Example[dev.yaml](config/dev.yaml):

```yaml
# ============================================
# Terraform Configuration - YAML Format
# ============================================
# NOTE: project.id and project.region are populated from environment variables
# via Terraform locals. See variables.tf for details.

# Project Settings
project:
  id: ""  # Will be overridden by TF_VAR_project_id
  region: ""  # Will be overridden by TF_VAR_region

# GCS Configuration
gcs:
  bucket:
    storage_class: "STANDARD"
    force_destroy: true  # Set to false in production
    public_access_prevention: "enforced"
    versioning_enabled: false

  # Data retention policy
  data_retention_days: 2

  # Dataset path relative to repository root
  dataset_subpath: "dbt/ecommerce_datahub/seeds/"
  # MIME type mappings for uploaded files
  content_types:
    csv: "text/csv"
    json: "application/json"
    txt: "text/plain"
    parquet: "application/octet-stream"

# BigQuery Configuration
bigquery:
  datasets:
    public:
      description: "Public dataset for open data and shared resources."
      location: "EU"
      default_table_expiration_ms: 3600000
    private:
      description: "Private dataset for internal work."
      location: "EU"
      default_table_expiration_ms: 3600000
    landing:
      description: "Landing dataset for raw data ingestion from external sources (GCS, APIs, etc)."
      location: "EU"
      default_table_expiration_ms: 3600000

  dbt_seeds:
    dbt_source_name: "ecommerce-data-landing_gcs"

iam_service_account:
  airflow:
    service_account_id: "airflow-runner-service-account"
    service_account_display_name: "Airflow Runner Service Account"
    required_roles:
      - "roles/bigquery.dataEditor"
      - "roles/bigquery.jobUser"
      - "roles/bigquery.user"
      - "roles/storage.objectViewer"

# Tags for all resources
tags:
  managed_by: "terraform"
  environment: "dev"
  project: "ecommerce-datahub"
```

The configuration file is automatically selected based on the active Terraform workspace.

Example:

| Workspace | Configuration |
|------------|---------------|
| dev | `config/dev.yaml` |
| qa | `config/qa.yaml` |
| prod | `config/prod.yaml` |

---

## Cheatsheet for Terraform commands

```bash
# Initialize terraform
terraform init

# Create dev workspace
terraform workspace new dev

# Select dev workspace
terraform workspace select dev

# Validate Configuration
terraform validate

# Format Configuration
terraform fmt -recursive

# Review changes before applying
terraform plan

# Apply changes to the environment
terraform apply
```