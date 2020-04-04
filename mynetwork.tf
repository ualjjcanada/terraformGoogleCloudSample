# Para mas detalles (opocional): export TF_LOG=TRACE


# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name                    = "mynetwork-tf"
  auto_create_subnetworks = "true"
  project                 = "${var.gcp_project}"
}

# Add a firewall rule to allow HTTP, SSH, RDP, and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
  name    = "mynetwork-tf-allow-http-ssh-rdp-icmp"
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
module "jenkins-vm" {
  source              = "./instance"
  instance_name       = "jenkins-vm-tf"
  instance_region     = "us-central1"
  instance_zone       = "us-central1-a"
  instance_type       = "n1-standard-2"
  image               = "ubuntu-os-cloud/ubuntu-1804-lts"
#  startup_script      = "${var.init_scrip_docker}"
  instance_subnetwork = google_compute_network.mynetwork.self_link
}

# Create the web-deploy-vm" instance
module "web-deploy-vm" {
  source              = "./instance"
  instance_name       = "web-deploy-vm-tf"
  instance_region     = "us-central1"
  instance_zone       = "us-central1-a"
  instance_type       = "n1-standard-1"
  image               = "ubuntu-os-cloud/ubuntu-1804-lts"
#  startup_script      = "${var.init_scrip_apache2}"
  instance_subnetwork = google_compute_network.mynetwork.self_link
}


resource "null_resource" "execute" {

 provisioner "remote-exec" {
    connection {
      host     = "${module.jenkins-vm.instance_ip_addr}"
      type     = "ssh"
      user     = "ubuntu"
      private_key  = "${file("~/.ssh/id_rsa")}"
    }

    ## Script inicialización jenkins-vm
    inline = [
       "sudo apt-get update -y",
       "echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections",
       "sudo apt-get upgrade -y",
       "sudo apt-get install -y python-minimal",
       "sudo timedatectl set-timezone Europe/Madrid",
       ##       "sudo reboot -h now"       
       "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
       "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -", 
       "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
       "sudo apt update -y", 
       "sudo apt install docker-ce -y",
       "sudo usermod -aG docker $${USER}",
      ]
    on_failure = "continue"
  }



 provisioner "remote-exec" {
    connection {
      host     = "${module.web-deploy-vm.instance_ip_addr}"
      type     = "ssh"
      user     = "ubuntu"
      private_key  = "${file("~/.ssh/id_rsa")}"
    }

    ## Script inicialización web-deploy-vm
    inline = [
       "sudo apt-get update -y",
       "echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections",
       "sudo apt-get upgrade -y",
       "sudo apt-get install -y python-minimal",
       "sudo timedatectl set-timezone Europe/Madrid",
       # Instalación de docker       
       "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
       "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -", 
       "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
       "sudo apt update -y", 
       "sudo apt install docker-ce -y",
       "sudo usermod -aG docker $${USER}",
       # Instalación de docker compose
       "sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
       "sudo chmod +x /usr/local/bin/docker-compose",
       # Instalacion de Java jdk 8
       "sudo apt install openjdk-8-jdk -y",
       "echo JAVA_HOME=\"/usr/lib/jvm/java-8-openjdk-amd64/jre\" | sudo tee -a /etc/environment",
       # Instalacion de Node JS
       "sudo apt install nodejs -y", 
       "sudo apt install npm -y"

      ]
    on_failure = "continue"
  }
  depends_on = [
    # Init script must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    module.web-deploy-vm.instance_ip_addr,  module.jenkins-vm.instance_ip_addr
  ]
}
