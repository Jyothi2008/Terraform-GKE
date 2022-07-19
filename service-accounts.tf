resource "google_service_account" "k8s-service-account" {
    account_id   = "k8s-service-account"
}

resource "google_project_iam_member" "k8s-iam-member" {
    project = "abdo-project-12345-354211"
    role    = "roles/container.admin"
    member  = "serviceAccount:${google_service_account.k8s-service-account.email}"
}