resource "google_bigquery_dataset" "db" {
  dataset_id  = "${var.project_name}_dataset"
  description = "Dataset for ${var.project_name} project"
  location    = "US"
  project = google_project.project.project_id

  depends_on = [google_project_service.project_service]
}

module "schemas" {
  source     = "./tables"
  project_id = google_project.project.project_id
  dataset_id = google_bigquery_dataset.db.dataset_id

  depends_on = [google_bigquery_dataset.db]
}

module "functions" {
  source     = "./routines"
  project_id = google_project.project.project_id
  dataset_id = google_bigquery_dataset.db.dataset_id

  depends_on = [google_bigquery_dataset.db]
}

resource "null_resource" "build_schema" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/build_graphql_schema.sh"
    environment = {
      GCP_LOGGING_CREDENTIALS = var.GCP_LOGGING_CREDENTIALS
      GCP_LOGGING_PROJECT_ID = var.GCP_LOGGING_PROJECT_ID
      LOG_NAME = "build_schema"
      BUCKET_NAME = "${var.bucket_name}-${var.project_name}-${var.DATASET_ENV}"
      R2_ACCOUNT_ID = var.R2_account_id
      R2_ACCESS_KEY_ID = var.R2_access_key_id
      R2_ACCESS_KEY_SECRET = var.R2_secret_access_key
      DATASET_ENV = var.DATASET_ENV
    }
  }

  depends_on = [module.schemas]
}
