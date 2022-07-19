resource "google_compute_instance" "private-vm" {
    name = "private-vm"
    machine_type = "f1-micro"
    zone = "${var.region}-a"
    tags = ["ssh"]//adding this tag to assign the ssh firewall to this instances only 
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
        }
    }
    network_interface {
        subnetwork  = google_compute_subnetwork.management_subnet.self_link
        network_ip = "10.0.1.2"
    }
}
