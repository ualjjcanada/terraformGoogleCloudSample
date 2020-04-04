variable "instance_name" {}
variable "instance_zone" {}
variable "instance_type" {
  default = "n1-standard-1"
}
variable "image"{
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
variable "instance_subnetwork" {}

# New static External IP for the VM
resource "google_compute_address" "static_public_ip" {
  name = "ipv4-address"
}

# New VM
resource "google_compute_instance" "vm_instance" {
  name         = "${var.instance_name}"
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"
  boot_disk {
    initialize_params {
      image = "${var.image}"
      }
  }

  # Add SSH access to the Compute Engine instance
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  # Startup script
  metadata_startup_script = "sudo apt-get update; sudo apt-get install apache2 -y"

  network_interface {
    network = "${var.instance_subnetwork}"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
      nat_ip = google_compute_address.static_public_ip.address
      network_tier="STANDARD"  # PREMIUM or STANDARD. If this field is not specified, it is assumed to be PREMIUM.
    }
  }
}