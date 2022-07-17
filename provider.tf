provider "google" {
    credentials = "${file("service-account.json")}"
    project = "abdo-project-12345-354211"
    region = "us-central1"
    zone = "us-central1-a"
}

