resource "google_bigquery_table" "configuration" {
  dataset_id          = var.dataset_id
  table_id            = "configuration"
  deletion_protection = false
  project             = var.project_id
  schema              = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "config_name",
    "type": "STRING"
  },
  {
    "name": "config_value",
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
