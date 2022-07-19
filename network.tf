resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"

}
resource "google_compute_subnetwork" "management_subnet" {
  name          = "management-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.my_vpc.id
}
resource "google_compute_subnetwork" "restricted_subnet" {
  name          = "restricted-subnetwork"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.my_vpc.id
}