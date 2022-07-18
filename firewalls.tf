resource "google_compute_firewall" "allow-ssh" {
    name        = "ssh-firewall"
    network     = google_compute_network.my_vpc.name
    description = "Creates firewall rule allow to ssh from anywhere"
    source_ranges = ["0.0.0.0/0"]
    allow {
    protocol  = "tcp"
    ports     = ["22"]
    }
}
