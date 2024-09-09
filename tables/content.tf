resource "google_bigquery_table" "content" {
  dataset_id          = var.dataset_id
  table_id            = "content"
  deletion_protection = false
  project             = var.project_id
  schema              = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "key",
    "type": "STRING"
  },
  {
    "name": "group_key",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "language",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "version",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "content_text",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "created_by",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "name": "updated_by",
    "mode": "REQUIRED",
    "type": "STRING"
  },
  {
    "defaultValueExpression": "CURRENT_TIMESTAMP",
    "name": "created_at",
    "type": "TIMESTAMP",
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
