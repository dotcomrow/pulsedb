resource "google_bigquery_table" "feature_flags" {
  dataset_id          = var.dataset_id
  table_id            = "feature_flags"
  deletion_protection = false
  project             = var.project_id
  schema              = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "id",
    "type": "STRING",
    "defaultValueExpression": "GENERATE_UUID()"
  },
  {
    "mode": "REQUIRED",
    "name": "feature_name",
    "type": "STRING"
  },
  {
    "name": "feature_type",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "page_id",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "condition",
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
