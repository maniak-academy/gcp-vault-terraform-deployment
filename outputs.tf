// A variable for extracting the external IP address of the instance
output "ip" {
 description = "The external IP for vault server"
 value = google_compute_instance.vault-maniak.network_interface.0.access_config.0.nat_ip
}
output "dns" {
 value = google_dns_record_set.vault-maniak-dns.name
}
