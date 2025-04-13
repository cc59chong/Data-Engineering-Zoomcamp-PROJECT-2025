
# Terraform Block: Specifies the required providers for the project

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

# Google Provider Configuration

provider "google" {
  # Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
  #  credentials = 
  project = "de-zoomcamp-project-456204"
  region  = "us-west1"
}

# Google Cloud Storage Bucket

resource "google_storage_bucket" "raw_bucket" {
  name     = "m5-sales-raw-bucket"
  location = "US"

  # Optional, but recommended settings:
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  # Deletes the bucket and all its objects when the resource is destroyed
  force_destroy = true

  versioning {
    enabled = true
  }

  # Deletes objects that are older than 30 days
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 // days
    }
  }
}

resource "google_storage_bucket" "cleaned_bucket" {
  name     = "m5-sales-cleaned-bucket"
  location = "US"

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

# Google BigQuery Dataset

resource "google_bigquery_dataset" "m5_dataset" {
  dataset_id = "m5_sales_data"
  project    = "de-zoomcamp-project-456204"
  location   = "US"
}

# Outputs

output "raw_bucket_name" {
  value = google_storage_bucket.raw_bucket.name
}

output "cleaned_bucket_name" {
  value = google_storage_bucket.cleaned_bucket.name
}

output "dataset_id" {
  value = google_bigquery_dataset.m5_dataset.dataset_id
}
