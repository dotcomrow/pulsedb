resource "random_id" "suffix" {
  byte_length = 8
}

resource "google_project" "project" {
  name       = "${var.project_name}-${var.DATASET_ENV}"
  project_id = "${var.project_name}-${random_id.suffix.hex}"
  org_id     = "${var.gcp_org_id}"
  billing_account = "${var.billing_account}"
}

resource "google_project_service" "project_service" {
  count = length(var.apis)

  disable_dependent_services = true
  project = google_project.project.project_id
  service = var.apis[count.index]
}

data "google_compute_default_service_account" "default" {
  project = google_project.project.project_id

  depends_on = [ google_project_service.project_service ]
}

resource "google_project_iam_member" "registry_permissions" {
  project = var.common_project_id
  role   = "roles/composer.environmentAndStorageObjectViewer"
  member  = "serviceAccount:service-${google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_compute_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "secret_manager_grant" {
  project = var.common_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
