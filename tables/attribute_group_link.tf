resource "google_bigquery_table" "attribute_group_link" {
  dataset_id = var.dataset_id
  table_id   = "attribute_group_link"
  deletion_protection = false
  project                     = var.project_id
  schema = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "attribute_group_link_id",
    "type": "INTEGER"
  },
  {
    "mode": "REQUIRED",
    "name": "attribute_id",
    "type": "INTEGER"
  },
  {
    "mode": "REQUIRED",
    "name": "group_id",
    "type": "INTEGER"
  }
]
EOF
}