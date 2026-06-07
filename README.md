# GCP Telemetry: Anomaly Forecasting & Predictive Alerting Control Center

This repository contains a production-grade, out-of-the-box infrastructure provisioning package and sandbox interface designed to implement **ML-driven Anomaly Forecasting & Predictive Alerting** natively on Google Cloud Platform. 

It provides an elegant, zero-ops, serverless alternative to Kibana Machine Learning, allowing any enterprise or team using **Cloud Logging**, **Cloud Monitoring**, and **Google Managed Service for Prometheus (GMP)** to automate capacity forecasting and log anomaly detection without managing dedicated ML clusters.


---

### 🖥️ Live Sandbox Interface Showcase

| 📈 1. Standard ARIMA Forecasting & Predictive Capacity Planning |
| :--- |
| ![Standard ARIMA Forecasting Dashboard](screenshots/dashboard_normal.png) |

| 🧠 2. Graph Neural Network Topology Mapping (Nominal State) | 🚨 3. Cascading Failure Threat Propagation (Anomaly Injected) |
| :--- | :--- |
| ![Nominal GNN Topology Mapping](screenshots/dashboard_gnn_normal.png) | ![GNN Cascading Threat Wave](screenshots/dashboard_gnn_cascade.png) |

---

## 🏗️ ELK-to-GCP Architectural Mapping

Google Cloud offers highly scalable, zero-ops alternatives that match or exceed Kibana's machine learning capabilities:

| Kibana ML / ELK Feature | GCP Native Replacement | Architectural Justification |
| :--- | :--- | :--- |
| **Kibana Anomaly Detection** (Metrics) | **Cloud Monitoring Predictive Alerts + PromQL/MQL Dynamic Limits** | Prometheus metrics reside natively in Cloud Monitoring (Monarch). We use **Predictive Alerting** (which projects metrics into the future using native linear engines) and sliding-window standard deviations for dynamic thresholds. |
| **Kibana Log Anomaly Detection** (App Logs) | **Cloud Logging Log Analytics (BigQuery) + BigQuery ML (BQML)** | Upgrading logging buckets to **Log Analytics** exposes log tables in BigQuery. BigQuery ML's `ARIMA_PLUS` models handle automatic holiday effects, level shifts, and outlier scrubbing in simple SQL. |
| **Kibana Forecasting** (Capacity Trends) | **BigQuery ML `ML.FORECAST` & PromQL `predict_linear`** | For capacity planning (such as disk or memory exhaustion), BQML's forecasting or GMP's `predict_linear` functions project resource exhaustion dates with statistical confidence. |

---

## 🛠️ Step-by-Step GCP Deployment Guide

This guide will walk you through authenticating with GCP, initializing Terraform, provisioning your alert policies, enabling Log Analytics, and training your first BigQuery ML time-series model.

### Prerequisites
Before you begin, ensure you have the following installed on your system:
*   [Google Cloud SDK (gcloud CLI)](https://cloud.google.com/sdk/docs/install)
*   [Terraform CLI (v1.3.0+)](https://developer.hashicorp.com/terraform/downloads)
*   A GCP project (such as `gke-demos-363017`) with the billing, logging, monitoring, and BigQuery APIs enabled.

---

### Step 1: Authenticate with Google Cloud
Open your terminal and authenticate your gcloud CLI and local Terraform environment with your GCP account:

```bash
# Log in to your GCP account
gcloud auth login

# Set your active project context
gcloud config set project gke-demos-363017

# Generate Application Default Credentials (ADC) for Terraform to use
gcloud auth application-default login
```

---

### Step 2: Deploy Infrastructure via Terraform
We provide a complete, modular Terraform suite that automates the deployment of Log Analytics, Cloud Monitoring alert rules, and our custom dashboard.

1.  Navigate to the `terraform/` directory:
    ```bash
    cd terraform/
    ```
2.  Initialize the Terraform workspace and download the Google provider plugins:
    ```bash
    terraform init
    ```
3.  Generate an execution plan to verify what resources will be created:
    ```bash
    terraform plan -var="project_id=gke-demos-363017"
    ```
4.  Apply the configuration to provision the resources:
    ```bash
    terraform apply -var="project_id=gke-demos-363017" -auto-approve
    ```

#### What Terraform provisions:
*   **Log Analytics:** Enables SQL queries natively on your logging bucket (`_Default` by default) via `google_logging_project_bucket_config`.
*   **Log-Based Metrics:** Creates `servicenow_incident_count` to count and extract incident labels (country, site) from incoming logs.
*   **BigQuery ML Dataset & Job:** Provisions the `telemetry_anomaly_forecasts` dataset and runs a BQ query job to train your multi-series `ARIMA_PLUS` time-series forecasting model.
*   **Predictive Alert Policies:** Configures native Cloud Monitoring alert policies utilizing `forecast_options` with forecasting horizons for Disk, RAM, and CPU capacity.
*   **Custom Monitoring Dashboard:** Provisions a gorgeous, custom dashboard displaying metric timeseries, capacity trends, and log metrics.

---

### Step 3: Run SQL Anomaly Detection and Forecasts in BigQuery
Once your Log Analytics bucket is upgraded and your BQML model is trained by Terraform, you can run advanced SQL queries directly in the BigQuery Console to detect historical outliers or project future peaks:

#### 1. Detect Historical Log Anomalies (Outliers)
```sql
SELECT * FROM ML.DETECT_ANOMALIES(
  MODEL `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_model`,
  STRUCT(0.99 AS anomaly_prob_threshold)
)
ORDER BY timestamp DESC;
```

#### 2. Forecast Future Log Volumes (14-Day Horizon)
```sql
SELECT 
  forecast_time, 
  forecast_value,
  prediction_interval_lower_bound,
  prediction_interval_upper_bound
FROM ML.FORECAST(
  MODEL `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_model`,
  STRUCT(14 AS horizon, 0.95 AS confidence_level)
)
ORDER BY forecast_time ASC;
```

#### 3. Advanced Model Evaluation (ARIMA order, seasonal components, AIC, BIC)
Evaluate candidate models and view statistical diagnostic information to determine model quality (such as Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC)):
```sql
SELECT * 
FROM ML.ARIMA_EVALUATE(
  MODEL `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_model`
);
```

#### 4. Explain Forecast (Decompose trend, seasonal, holiday, and step-changes)
Deconstruct and explain the individual trend components, seasonal patterns (weekly, daily), holiday effects, and step changes within your predicted timeline:
```sql
SELECT * 
FROM ML.EXPLAIN_FORECAST(
  MODEL `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_model`,
  STRUCT(14 AS horizon, 0.95 AS confidence_level)
);
```

#### 5. Retrieve ARIMA Coefficients (Inspect mathematically calculated weights)
Extract the Auto-Regressive (AR) coefficients, Moving Average (MA) coefficients, drift, and intercept parameters calculated by the model's training solver:
```sql
SELECT * 
FROM ML.ARIMA_COEFFICIENTS(
  MODEL `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_model`
);
```

#### 6. Instantly Query Pre-Configured Live BigQuery Views
To streamline analysis, Terraform automatically deploys four pre-configured views within your BigQuery dataset that dynamically call these BigQuery ML functions for you. You don't need to write the complex mathematical query syntax; simply query them like standard tables:

*   **Live 14-Day Forecasts View:**
    ```sql
    SELECT * FROM `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_forecast_view` LIMIT 100;
    ```
*   **Live Anomalies/Outliers View:**
    ```sql
    SELECT * FROM `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_anomalies_view` LIMIT 100;
    ```
*   **Model Evaluation Diagnostics View:**
    ```sql
    SELECT * FROM `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_evaluation_view`;
    ```
*   **Model Coefficients View:**
    ```sql
    SELECT * FROM `gke-demos-363017.telemetry_anomaly_forecasts.incident_volume_coefficients_view`;
    ```

---

### Step 4: Verify Alerts and Custom Dashboards in the GCP Console
At the end of your `terraform apply`, Terraform will output a direct console link to your custom dashboard:

```text
dashboard_console_url = "https://console.cloud.google.com/monitoring/dashboards/custom/DASHBOARD_UUID?project=gke-demos-363017"
```

1.  Copy and paste this URL into your browser to view your live, native GCP dashboard.
2.  Navigate to **Cloud Monitoring > Alerting** in the Google Cloud Console to inspect the three predictive alerts. They are now actively monitoring and forecasting capacity thresholds on your k8s cluster nodes!


---

## 🧠 Graph Neural Networks (GNNs) & Topology Cascades on GCP

Linear anomaly forecasting models (like ARIMA) are exceptionally powerful for isolated time-series streams but fail to capture the **complex, multi-hop relationship dependencies** inherent to microservice and cluster topologies. For example, a slow memory leak in a downstream database (`Payment DB`) eventually cascades upwards as latency spikes in `Payment Service`, then HTTP rate limits in the `API Gateway`, before finally blowing up connection pools at the ingress `Load Balancer`.

To deeply understand and forecast these propagation risks, we implement a **Graph Neural Network (GNN)** architecture deployed natively on GCP using **BigQuery Graph** (graph property schemas) and **Vertex AI Endpoints** serving **PyTorch Geometric (PyG)** models.

### GNN Architectural & MLOps Pipeline on GCP

```mermaid
graph LR
    subgraph Storage & Schema [BigQuery Graph]
        A[(graph_nodes)] -->|NODE TABLE| C(Property Graph)
        B[(graph_edges)] -->|EDGE TABLE| C
    end
    
    subgraph Model Training [Vertex AI Pipelines]
        C -->|GQL Export| D[PyG GraphConv Network]
        D -->|Train / Embed| E[GNN Model Artifacts]
    end
    
    subgraph Serving & Alerting [Vertex AI & Cloud Monitoring]
        E -->|Deploy| F[Vertex AI Endpoint]
        F -->|Real-Time Inference| G[Cascade Risk %]
        G -->|Log Custom Metric| H[Predictive Incident Alerts]
    end
```

#### 1. Graph Relational Modeling with BigQuery Graph
We natively declare a graph property schema in BigQuery using SQL GQL (Graph Query Language). This allows us to map service dependencies as nodes and edges without managing complex Neo4j or GraphDB clusters:
```sql
CREATE OR REPLACE PROPERTY GRAPH `gke-demos-363017.telemetry_anomaly_forecasts.topology_graph`
NODE TABLES (
  `gke-demos-363017.telemetry_anomaly_forecasts.graph_nodes`
    KEY (node_id)
    LABEL Node { node_name, service_type }
)
EDGE TABLES (
  `gke-demos-363017.telemetry_anomaly_forecasts.graph_edges`
    KEY (edge_id)
    SOURCE KEY (source_id) REFERENCES graph_nodes (node_id)
    DESTINATION KEY (destination_id) REFERENCES graph_nodes (node_id)
    LABEL DEPENDS_ON { dependency_type }
);
```

To extract multi-hop dependencies or simulate an impact blast radius, we query the graph using path traversal:
```sql
-- Trace 1-to-3 hop upstream dependencies starting from a database outage
SELECT source_node, dest_node, path
FROM GRAPH_TABLE(
  `gke-demos-363017.telemetry_anomaly_forecasts.topology_graph`
  MATCH (src:Node {node_name: "Payment DB"})<-[e:DEPENDS_ON*1..3]-(dst:Node)
  COLUMNS(src.node_name AS source_node, dst.node_name AS dest_node, JSON_ARRAY(e.dependency_type) AS path)
);
```

#### 2. PyTorch Geometric (PyG) Model Architecture
The GNN is trained as a node classification and link risk prediction model using **Graph Convolutional Networks (GCNs)**. The model convolves node attributes (CPU, Memory, error rates) over the neighborhood structure to calculate a downstream cascading failure risk:

```python
import torch
import torch.nn.functional as F
from torch_geometric.nn import GCNConv

class GNNTopologyCascadePredictor(torch.nn.Module):
    def __init__(self, num_node_features, hidden_dim):
        super(GNNTopologyCascadePredictor, self).__init__()
        # Graph convolution layers convolve node features with topology connectivity
        self.conv1 = GCNConv(num_node_features, hidden_dim)
        self.conv2 = GCNConv(hidden_dim, hidden_dim)
        self.out = torch.nn.Linear(hidden_dim, 1) # Outputs cascade risk probability [0, 1]

    def forward(self, x, edge_index):
        # x is the node feature matrix; edge_index represents the topology links
        x = self.conv1(x, edge_index)
        x = F.relu(x)
        x = F.dropout(x, p=0.1, training=self.training)
        x = self.conv2(x, edge_index)
        x = F.relu(x)
        return torch.sigmoid(self.out(x))
```

#### 3. Vertex AI Real-Time Endpoint Serving
Once trained, the GNN model artifacts are packaged in a Docker container and deployed to the newly provisioned `google_vertex_ai_endpoint.gnn_endpoint` (`us-central1`).
*   **Inference Payload:** A live snapshot of current microservice CPU/Memory metrics (node features) along with the active BigQuery graph topological links (edge index).
*   **Response Payload:** A live cascade failure risk mapping representing the propagation probability for each service in the graph.

---

## 🚀 Running the Local Interactive Demo Sandbox

To run the client-side telemetry simulator and visualize these mathematical algorithms in real-time, launch our high-fidelity hot-reloading dashboard locally:

### Method A: Vite Dev Server (Recommended)
1.  Make sure you have [Node.js](https://nodejs.org/) installed.
2.  In the repository root, install Vite and run the dev server:
    ```bash
    npm install
    npm run dev
    ```
3.  Open the printed local URL (typically `http://localhost:5173`) in your browser to interact with the sandbox.

### Method B: Double-Click File Ingest (Zero Dependencies)
Because our interactive interface fetches Chart.js, Lucide Icons, and Google Fonts from reliable global CDNs, you can run the full app without Node:
1.  Navigate to the repository folder on your machine.
2.  Double-click `index.html` to load the premium dashboard directly in your default browser.
