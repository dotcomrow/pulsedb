resource "google_bigquery_table" "user_info" {
  dataset_id          = var.dataset_id
  table_id            = "user_info"
  deletion_protection = false
  project             = var.project_id
  schema              = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "id",
    "type": "STRING"
  },
  {
    "name": "preferences",
    "mode": "REQUIRED",
    "type": "JSON"
  },
  {
    "name": "private_key",
    "type": "JSON",
    "mode": "REQUIRED"
  },
  {
    "name": "public_key",
    "type": "JSON",
    "mode": "REQUIRED"
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
