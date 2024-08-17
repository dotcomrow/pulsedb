resource "google_bigquery_table" "requests" {
  dataset_id          = var.dataset_id
  table_id            = "requests"
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
    "name": "request_url",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "request_method",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "request_headers",
    "mode": "REQUIRED",
    "type": "JSON"
  },
  {
    "name": "request_query",
    "mode": "REQUIRED",
    "type": "JSON"
  },
  {
    "name": "request_body",
    "mode": "REQUIRED",
    "type": "JSON"
  },
  {
    "name": "schedule",
    "mode": "REQUIRED",
    "type": "STRING"
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
