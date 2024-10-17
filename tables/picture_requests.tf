resource "google_bigquery_table" "picture_requests" {
  dataset_id          = var.dataset_id
  table_id            = "picture_requests"
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
  },
  {
    "name": "location",
    "type": "GEOGRAPHY",
    "mode": "REQUIRED"
  },
  {
    "name": "direction",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  }
]
EOF
}