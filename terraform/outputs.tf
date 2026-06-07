output "project_id" {
  value       = var.project_id
  description = "The GCP Project ID where resources were deployed."
}

output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.telemetry_dataset.dataset_id
  description = "The ID of the BigQuery Dataset created."
}

output "log_based_metric" {
  value       = google_logging_metric.servicenow_incidents.name
  description = "The name of the log-based metric extracted from ServiceNow incident logs."
}

output "disk_exhaustion_alert" {
  value       = google_monitoring_alert_policy.disk_exhaustion_forecast.name
  description = "The resource ID of the Disk Capacity Exhaustion predictive alert policy."
}

output "memory_exhaustion_alert" {
  value       = google_monitoring_alert_policy.memory_exhaustion_forecast.name
  description = "The resource ID of the RAM Capacity Exhaustion predictive alert policy."
}

output "cpu_exhaustion_alert" {
  value       = google_monitoring_alert_policy.cpu_exhaustion_forecast.name
  description = "The resource ID of the CPU Exhaustion predictive alert policy."
}

output "dashboard_id" {
  value       = google_monitoring_dashboard.telemetry_forecasting_dashboard.id
  description = "The resource ID of the Cloud Monitoring Dashboard."
}

output "dashboard_console_url" {
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${element(split("/", google_monitoring_dashboard.telemetry_forecasting_dashboard.id), 3)}?project=${var.project_id}"
  description = "The direct Google Cloud Console URL to view your newly created Anomaly Forecasting Dashboard."
}

output "bigquery_forecast_view" {
  value       = google_bigquery_table.incident_volume_forecast_view.table_id
  description = "The Table ID of the BigQuery View pre-configured for live 14-day forecasts."
}

output "bigquery_anomalies_view" {
  value       = google_bigquery_table.incident_volume_anomalies_view.table_id
  description = "The Table ID of the BigQuery View pre-configured for live historical anomaly detection."
}

output "bigquery_evaluation_view" {
  value       = google_bigquery_table.incident_volume_evaluation_view.table_id
  description = "The Table ID of the BigQuery View pre-configured for ARIMA model evaluation diagnostics."
}

output "bigquery_coefficients_view" {
  value       = google_bigquery_table.incident_volume_coefficients_view.table_id
  description = "The Table ID of the BigQuery View pre-configured for ARIMA model coefficients."
}

