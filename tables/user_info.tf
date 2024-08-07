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
    "type": "INTEGER"
    "type": "JSON"
  },
  {
    "name": "updated_at",
    "type": "TIMESTAMP"
    "type": "REQUIRED"
  },
  {
    "name": "private_key",
    "type": "JSON"
    "type": "REQUIRED"
  },
  {
    "name": "public_key",
    "type": "JSON"
    "type": "REQUIRED"
  }
]
EOF
}
