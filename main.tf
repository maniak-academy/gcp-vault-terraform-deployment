terraform {
  backend "remote" {
    organization = "ManiakVenturesInc"

    workspaces {
      name = "gcp-vault-terraform-deployment"
    }
  }
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}


provider "google" {
  credentials = file("./certs/maniak-io-60c003ee1531.json")
  project = "maniak-io"
  region  = "us-central1"
  zone    = "us-central1-c"
}
// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 4
}

// A single Compute Engine instance
resource "google_compute_instance" "vault-maniak" {
 name         = "vault-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-central1-c"

 tags = ["env", "vault"]

 boot_disk {
   initialize_params {
     image = "ubuntu-os-cloud/ubuntu-1804-lts"
   }
 }
 metadata = {
   ssh-keys = "ubuntu:${file("./certs/vault-gcp.pub")}"
 }



// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync certbot unzip jq; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

resource "google_dns_record_set" "vault-maniak-dns" {
  managed_zone = "maniak"
  name         = "vault.maniak.io."
  type         = "A"
  rrdatas      = [google_compute_instance.vault-maniak.network_interface.0.access_config.0.nat_ip]
  ttl          = 600
}