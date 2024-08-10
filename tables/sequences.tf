resource "google_bigquery_table" "sequences" {
  dataset_id = var.dataset_id
  table_id   = "sequences"
  deletion_protection = false
  project                     = var.project_id
  schema = <<EOF
[
  {
    "mode": "REQUIRED",
    "name": "sequence_name",
    "type": "STRING"
  },
  {
    "name": "sequence_value",
    "type": "INTEGER"
  }
]
EOF
}