resource "google_bigquery_routine" "get_row_id" {
  dataset_id      = var.dataset_id
  routine_id      = "get_row_id"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  project = var.project_id
  
  arguments {
    name = "sequence_name"
    data_type = "{\"typeKind\" :  \"STRING\"}"
  } 
  definition_body = templatefile("${path.module}/../templates/get_row_id.template", { dataset = var.dataset_id })
}