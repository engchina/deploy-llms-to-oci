## Copyright © 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "fastchat_bootstrap_template" {
  template = templatefile("./userdata/fastchat.tpl", {
    llm_fastchat_model = var.llm_fastchat_model
  })
}