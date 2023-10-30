output "instance_public_ips" {
  value = (var.llm_tool == "Text generation web UI") ? [
    oci_core_instance.textgen_instance.*.public_ip
  ] : ((var.llm_tool == "Fooocus") ? [oci_core_instance.sd_instance.*.public_ip] : ((var.llm_tool == "FastChat") ? [
    oci_core_instance.fastchat_instance.*.public_ip
  ] : []))
}