resource "google_bigquery_table" "picture_responses" {
  dataset_id          = var.dataset_id
  table_id            = "picture_responses"
  deletion_protection = false
  project             = var.project_id
  schema              = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "account_id",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "request_id",
    "type": "STRING",
    "defaultValueExpression": "GENERATE_UUID()"
  },
  {
    "defaultValueExpression": "CURRENT_TIMESTAMP",
    "name": "updated_at",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  }
]
EOF
}