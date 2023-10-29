variable "region" {
}

variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "availability_domain_name" {
}

variable "subnet_ocid" {
}

variable "ssh_public_key" {
}

variable "instance_shape" {
  default = "VM.GPU.A10.1"
}

variable "display_name" {
  default = "ai-instance"
}

variable "instance_image_ocid" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/ => https://docs.oracle.com/en-us/iaas/images/image/dc8dcb88-c8a7-4248-8a57-9e4693d8fe45/
    # Oracle-provided image "Oracle-Linux-8.8-Gen2-GPU-2023.09.26-0"
    ap-osaka-1   = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa2ao3ifxj5amnicordfojokozcxaegxnlhamwpce2r7kx6xwqvivq"
    ap-tokyo-1   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaanajh2h7kutywf7p26z7ujsz7vc6rtm6irkahulh7z2m3qxt7qq7q"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaausn7x2mwftcv3klzj34rr6rvpr5exs5obi7jkw4jqbotqeqzubna"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaakaymhddrjzuuy35n76c7rlavl2het5wpw4djdqg65vap6t4xtpsa"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaadfe3nnzg6mprq7p7msjeyb4lmwe3zj2tkod7kzovdrlniracqjuq"
  }
}

variable "bv_size" {
  default = "200" # size in GBs
}