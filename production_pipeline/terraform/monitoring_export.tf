# BigQuery Dataset to receive Cloud Monitoring BigQuery Export metrics
# Note: Google Cloud Monitoring allows continuous streaming of metrics to BigQuery
# via Console settings: Monitoring > Settings > BigQuery Export.
# We set location to "US" (multi-region) to match the global Log Analytics dataset location,
# enabling cross-table correlation queries.
resource "google_bigquery_dataset" "metrics_export" {
  project                    = var.project_id
  dataset_id                 = var.metrics_export_dataset_id
  location                   = "US"
  description                = "Target dataset for continuous export of Cloud Monitoring & Prometheus metrics"
  delete_contents_on_destroy = true
}

# Pre-create the time_series table with the correct schema
# This allows SQL views and GNN extraction scripts to compile and initialize immediately,
# even before the continuous export is enabled in the GCP Console.
resource "google_bigquery_table" "time_series" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.metrics_export.dataset_id
  table_id            = "time_series"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "metric",
    "type": "RECORD",
    "mode": "NULLABLE",
    "fields": [
      {"name": "type", "type": "STRING", "mode": "NULLABLE"},
      {
        "name": "labels",
        "type": "RECORD",
        "mode": "NULLABLE",
        "fields": [
          {"name": "source_workload", "type": "STRING", "mode": "NULLABLE"},
          {"name": "destination_workload", "type": "STRING", "mode": "NULLABLE"},
          {"name": "destination_service_name", "type": "STRING", "mode": "NULLABLE"}
        ]
      }
    ]
  },
  {
    "name": "resource",
    "type": "RECORD",
    "mode": "NULLABLE",
    "fields": [
      {"name": "type", "type": "STRING", "mode": "NULLABLE"},
      {
        "name": "labels",
        "type": "RECORD",
        "mode": "NULLABLE",
        "fields": [
          {"name": "instance_id", "type": "STRING", "mode": "NULLABLE"},
          {"name": "node_name", "type": "STRING", "mode": "NULLABLE"},
          {"name": "container_name", "type": "STRING", "mode": "NULLABLE"},
          {"name": "job", "type": "STRING", "mode": "NULLABLE"}
        ]
      }
    ]
  },
  {
    "name": "point",
    "type": "RECORD",
    "mode": "NULLABLE",
    "fields": [
      {
        "name": "value",
        "type": "RECORD",
        "mode": "NULLABLE",
        "fields": [
          {"name": "double_value", "type": "FLOAT", "mode": "NULLABLE"},
          {"name": "int64_value", "type": "INTEGER", "mode": "NULLABLE"}
        ]
      }
    ]
  }
]
EOF
}
