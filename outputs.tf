output "instance_public_ips" {
  value = [oci_core_instance.ai_instance.*.public_ip]
}