resource "google_bigquery_table" "responses" {
  dataset_id          = var.dataset_id
  table_id            = "responses"
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
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "response_id",
    "type": "STRING",
    "defaultValueExpression": "GENERATE_UUID()"
  },
  {
    "name": "response_status",
    "mode": "REQUIRED",
    "type": "INTEGER"
  },
  {
    "name": "response_headers",
    "mode": "REQUIRED",
    "type": "JSON"
  },
  {
    "name": "response_body",
    "mode": "REQUIRED",
    "type": "JSON"
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
