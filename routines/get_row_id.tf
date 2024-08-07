resource "google_bigquery_routine" "get_row_id" {
  dataset_id      = google_bigquery_dataset.main_dataset.dataset_id
  routine_id      = "get_row_id"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  
  arguments {
    name = "sequence_name"
    data_type = "{\"typeKind\" :  \"STRING\"}"
  } 
  definition_body = templatefile("${path.module}/templates/get_row_id.template", { dataset = google_bigquery_dataset.main_dataset.dataset_id })

  depends_on = [ google_bigquery_dataset.main_dataset ]
}