provider "google" {
    credentials = "${file("service-account.json")}"
    project = var.project
    region = "us-central1"
    zone = "us-central1-a"
}

