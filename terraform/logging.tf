# Enable Log Analytics on the Log Bucket (e.g. _Default)
# Note: Log Analytics is a permanent, irreversible upgrade on a logging bucket.
resource "google_logging_project_bucket_config" "default_analytics" {
  project          = var.project_id
  location         = "global"
  bucket_id        = var.bucket_id
  enable_analytics = true
}

# Create a Log-Based Metric to count and extract ServiceNow incident logs.
# This metric can be ingested by Cloud Monitoring or queried in PromQL/MQL.
resource "google_logging_metric" "servicenow_incidents" {
  project = var.project_id
  name    = "servicenow_incident_count"
  filter  = "jsonPayload.event=\"incident\" AND jsonPayload.message:\"ServiceNow incident created\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"

    labels {
      key         = "country"
      value_type  = "STRING"
      description = "The country where the incident was reported."
    }

    labels {
      key         = "site"
      value_type  = "STRING"
      description = "The specific site location where the incident occurred."
    }
  }

  label_extractors = {
    "country" = "EXTRACT(jsonPayload.country)"
    "site"    = "EXTRACT(jsonPayload.site)"
  }
}
