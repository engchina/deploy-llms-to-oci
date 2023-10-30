resource "oci_core_instance" "sd_instance" {
  count               = (var.llm_model == "Stable Diffusion") ? 1 : 0
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain_name
  display_name        = var.display_name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id                 = var.subnet_ocid
    display_name              = "Primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
  }

  source_details {
    boot_volume_size_in_gbs = var.bv_size
    boot_volume_vpus_per_gb = "10"
    source_type             = "image"
    source_id               = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("./userdata/stable-diffusion"))
  }

  timeouts {
    create = "60m"
  }
}

