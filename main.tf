# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "google" {
  project = "allweatherportfolioprotocol"
  credentials = file("service-account.json")
  region      = "europe-west1"
}

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE LOCALS
# ---------------------------------------------------------------------------------------------------------------------

# locals {
#   image_name = var.image_name == "" ? "${var.gcr_region}.gcr.io/${var.project}/${var.service_name}" : var.image_name
#   # uncomment the following line to connect to the cloud sql database instance
#   #instance_connection_name = "${var.project}:${var.location}:${google_sql_database_instance.master[0].name}"
# }

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloud_run_service" "service-backend" {
  name     = "backend"
  location = var.location
  project = var.project
  template {
    metadata {
      annotations = {
        "client.knative.dev/user-image" = "docker.io/davidtnfsh/rebalance-server:1.2"

        # uncomment the following line to connect to the cloud sql database instance
        #"run.googleapis.com/cloudsql-instances" = local.instance_connection_name
      }
    }

    spec {
      containers {
        image = "docker.io/davidtnfsh/rebalance-server:1.2"
        ports {
          name = "http1"
          container_port = 5000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth-backend" {
  location    = google_cloud_run_service.service-backend.location
  project     = google_cloud_run_service.service-backend.project
  service     = google_cloud_run_service.service-backend.name

  policy_data = data.google_iam_policy.noauth.policy_data
}