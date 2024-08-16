resource "random_id" "suffix" {
  byte_length = 8
}

resource "google_project" "project_dev" {
  name       = "${var.project_name}-dev"
  project_id = "${var.project_name}-${random_id.suffix.hex}"
  org_id     = "${var.gcp_org_id}"
  billing_account = "${var.billing_account}"
}

resource "google_project" "project_prod" {
  name       = "${var.project_name}-prod"
  project_id = "${var.project_name}-${random_id.suffix.hex}"
  org_id     = "${var.gcp_org_id}"
  billing_account = "${var.billing_account}"
}

resource "google_project_service" "project_service" {
  count = length(var.apis)

  disable_dependent_services = true
  project = google_project.project_dev.project_id
  service = var.apis[count.index]
}

resource "google_project_service" "project_service" {
  count = length(var.apis)

  disable_dependent_services = true
  project = google_project.project_prod.project_id
  service = var.apis[count.index]
}

data "google_compute_default_service_account" "default" {
  project = google_project.project_dev.project_id

  depends_on = [ google_project_service.project_service ]
}

data "google_compute_default_service_account" "default" {
  project = google_project.project_prod.project_id

  depends_on = [ google_project_service.project_service ]
}

resource "google_project_iam_member" "registry_permissions" {
  project = var.common_project_id
  role   = "roles/composer.environmentAndStorageObjectViewer"
  member  = "serviceAccount:service-${google_project.project_dev.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${google_project.project_dev.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_compute_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project.project_dev.number}-compute@developer.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "registry_permissions" {
  project = var.common_project_id
  role   = "roles/composer.environmentAndStorageObjectViewer"
  member  = "serviceAccount:service-${google_project.project_prod.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${google_project.project_prod.number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "artifact_compute_permissions" {
  project = var.common_project_id
  role   = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project.project_prod.number}-compute@developer.gserviceaccount.com"

  depends_on = [ data.google_compute_default_service_account.default ]
}

resource "google_project_iam_member" "developer_permissions" {
  project = google_project.project_dev.project_id
  role   = "roles/bigquery.dataViewer"
  member  = "group:developers@${var.domain}"

  depends_on = [ data.google_compute_default_service_account.default ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
