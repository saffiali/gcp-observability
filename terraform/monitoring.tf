# 1. Predictive Alert Policy: Predicted Disk Exhaustion in 7 days
resource "google_monitoring_alert_policy" "disk_exhaustion_forecast" {
  project      = var.project_id
  display_name = "Predictive Alert: Disk Capacity Exhaustion expected in 7 days"
  combiner     = "OR"

  conditions {
    display_name = "Predicted Disk Space Full < 100GB"
    condition_threshold {
      filter          = "metric.type=\"prometheus.googleapis.com/node_filesystem_free_bytes/gauge\" AND resource.type=\"k8s_node\""
      duration        = "300s"
      comparison      = "COMPARISON_LT"
      threshold_value = 107374182400 # under 100GB free

      forecast_options {
        forecast_horizon = "604800s" # 7 Days horizon
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  documentation {
    content   = "The disk space is predicted to drop below 100GB within the next 7 days based on the current consumption trend."
    mime_type = "text/markdown"
  }
}

# 2. Predictive Alert Policy: Predicted RAM Exhaustion in 3 days
resource "google_monitoring_alert_policy" "memory_exhaustion_forecast" {
  project      = var.project_id
  display_name = "Predictive Alert: Memory Exhaustion expected in 3 days"
  combiner     = "OR"

  conditions {
    display_name = "Predicted RAM Used > 95%"
    condition_threshold {
      filter          = "metric.type=\"prometheus.googleapis.com/node_memory_Active_bytes/gauge\" AND resource.type=\"k8s_node\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.95

      forecast_options {
        forecast_horizon = "259200s" # 3 Days horizon
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  documentation {
    content   = "Node physical memory (RAM) is predicted to exceed 95% utilization within the next 3 days based on current paging rates."
    mime_type = "text/markdown"
  }
}

# 3. Predictive Alert Policy: Predictive CPU Exhaustion in 4 hours
resource "google_monitoring_alert_policy" "cpu_exhaustion_forecast" {
  project      = var.project_id
  display_name = "Predictive Alert: CPU Exhaustion expected in 4 hours"
  combiner     = "OR"

  conditions {
    display_name = "Predicted CPU Used > 95%"
    condition_threshold {
      filter          = "metric.type=\"prometheus.googleapis.com/node_cpu_seconds_total/counter\" AND resource.type=\"k8s_node\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.95

      forecast_options {
        forecast_horizon = "14400s" # 4 Hours horizon
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  documentation {
    content   = "CPU utilization is predicted to exceed 95% within the next 4 hours based on the latest container workloads and scheduling peaks."
    mime_type = "text/markdown"
  }
}
