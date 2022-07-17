resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"

}
resource "google_compute_subnetwork" "public_subnet_1" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.my_vpc.id
}