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

resource "null_resource" "build_schema" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/build_graphql_schema.sh ${google_project.project.project_id} ${google_bigquery_dataset.db.dataset_id} ${var.bucket_name} ${var.R2_account_id} ${var.R2_access_key_id} ${var.R2_secret_access_key}"
  }

  depends_on = [module.schemas]
}
