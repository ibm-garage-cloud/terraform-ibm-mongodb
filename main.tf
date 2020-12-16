provider "ibm" {
  version = ">= 1.2.1"
}

data "ibm_resource_group" "tools_resource_group" {
  name = var.resource_group_name
}

locals {
  service           = "databases-for-mongodb"
  name_prefix       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name              = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-mongodb"
  resource_location = var.resource_location
}

// AppID - App Authentication
resource "ibm_resource_instance" "mongodb_instance" {
  name              = local.name
  service           = local.service
  plan              = var.plan
  location          = local.resource_location
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  tags              = var.tags

  timeouts {
    create = "30m"
    update = "15m"
    delete = "15m"
  }
}

data "ibm_resource_instance" "mongodb_instance" {
  depends_on        = [ibm_resource_instance.mongodb_instance]

  name              = local.name
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  location          = local.resource_location
  service           = local.service
}

resource "ibm_resource_key" "mongodb_key" {
  name                 = "${local.name}-key"
  role                 = var.role
  resource_instance_id = data.ibm_resource_instance.mongodb_instance.id

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
