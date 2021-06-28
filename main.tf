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
  credentials = file("vault-training-maniak-academy-fc4daf2ca521.json")
  project = "vault-training-maniak-academy"
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
   ssh-keys = "ubuntu:${file("vault-gcp.pub")}"
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}



resource "google_dns_record_set" "resource-recordset" {
  managed_zone = "maniakacademy-com"
  name         = "test-record.maniakacademy.com."
  type         = "A"
  rrdatas      = ["10.0.0.1", "10.1.0.1"]
  ttl          = 86400
}