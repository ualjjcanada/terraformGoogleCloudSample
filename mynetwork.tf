# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name                    = "mynetwork"
  auto_create_subnetworks = "true"
}

# Add a firewall rule to allow HTTP, SSH, RDP, and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
  name    = "mynetwork-allow-http-ssh-rdp-icmp"
  network = google_compute_network.mynetwork.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]
  }
  allow {
    protocol = "icmp"
  }
}

# Create the jenkins-vm instance
#module "jenkins-vm" {
#  source              = "./instance"
#  instance_name       = "jenkins-vm"
#  instance_zone       = "us-central1-a"
#  instance_type       = "n1-standard-2"
#  image               = "ubuntu-os-cloud/ubuntu-1804-lts"
#  instance_subnetwork = google_compute_network.mynetwork.self_link
#}

# Create the web-deploy-vm" instance
module "web-deploy-vm" {
  source              = "./instance"
  instance_name       = "web-deploy-vm-tf"
  instance_zone       = "europe-west1-d"
  instance_type       = "f1-micro"
  image               = "ubuntu-os-cloud/ubuntu-1804-lts"
  instance_subnetwork = google_compute_network.mynetwork.self_link
}