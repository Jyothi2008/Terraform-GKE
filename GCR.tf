resource "google_container_registry" "registry" {
    project  = var.project
    location = "US"
}

resource "google_storage_bucket_iam_member" "viewer" {
    bucket = google_container_registry.registry.id
    role = "roles/storage.objectViewer"
    member = "serviceAccount:${google_service_account.k8s-cluster.email}"
}
