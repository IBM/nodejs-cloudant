terraform {
  required_version = ">= 0.12"
  required_providers {
    ibm = {
    source = "IBM-Cloud/ibm"
    version = ">= 1.0.0"
    }
}
}

resource "random_string" "random" {
  length = 4
  min_lower = 4
}

resource "time_sleep" "wait_300_seconds" {
  depends_on = [ibm_container_cluster.cluster]

  create_duration = "300s"
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

provider "ibm" {
  ibmcloud_api_key   = var.ibmcloud_api_key
}

resource "ibm_container_cluster" "cluster" {
  name              = var.cluster_name
  datacenter        = var.datacenter
  default_pool_size = var.default_pool_size
  machine_type      = var.machine_type
  hardware          = var.hardware
  kube_version      = var.kube_version
  #public_vlan_id    = var.public_vlan_num
  #private_vlan_id   = var.private_vlan_num
  resource_group_id = data.ibm_resource_group.group.id
}

resource "ibm_resource_instance" "cloudant" {
  name              = "my-cloudant-db"
  service           = "cloudantnosqldb"
  plan              = "lite"
  location          = "us-south"
  resource_group_id = data.ibm_resource_group.group.id
  depends_on = [ibm_container_cluster.cluster]
}

resource "ibm_container_bind_service" "bind_service" {
  cluster_name_id       = var.cluster_name
  service_instance_name = ibm_resource_instance.cloudant.name
  namespace_id          = var.cluster_namespace
  resource_group_id = data.ibm_resource_group.group.id
}

module "ibm-kubernetes-toolchain" {
  source            = "github.com/marifse/ibm-kubernetes-toolchain-module"
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = "us-south"
  toolchain_name    = "cloudant-terraform-toolchain-node-${random_string.random.result}"
  application_repo  = "https://github.com/triceam/nodejs-cloudant"
  resource_group    = var.resource_group
  cluster_name      = var.cluster_name
  cluster_namespace = var.cluster_namespace
  container_registry_namespace = var.container_registry_namespace
  depends_on = [ibm_container_cluster.cluster]
}
