data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Grab the latest Oracle Linux image
data "oci_core_images" "ol8" {
  compartment_id = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  # Most recent image first
}

locals {
  ad_name   = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name
  image_id  = length(data.oci_core_images.ol8.images) > 0 ? data.oci_core_images.ol8.images[0].id : null
}

resource "oci_core_instance" "vm" {
  availability_domain = local.ad_name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  source_details {
    source_type             = "image"
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = var.assign_public_ip
    hostname_label   = replace(lower(var.instance_display_name), "/[^a-z0-9-]/", "-")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.cloud_init)
  }

  # Optional: preserve boot volume on termination
  lifecycle {
    ignore_changes = [metadata] # allows updating cloud-init variable without forcing replacement
  }
}

