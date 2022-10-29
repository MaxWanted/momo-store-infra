terraform {
  required_providers {
    yandex = {
      source  = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
      version = "0.72.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token #variable.tf
  cloud_id  = "b1gqokp4g93bklg01717"
  folder_id = "b1gk23jb7ovl195p0o9n"
  zone      = "ru-central1-c"
}


#create network
resource "yandex_vpc_network" "my-network" {
  name        = "my-network"
  description = "network for k8s"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

#create sub-network
resource "yandex_vpc_subnet" "my-subnet-network" {
  name           = "my-subnet-network"
  description    = "subnet for k8s"
  v4_cidr_blocks = ["10.0.0.0/21"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.my-network.id
}

#create service account
resource "yandex_iam_service_account" "cluster-account" {
  name        = "cluster-account"
  description = "k8s service account"
}


#set role "editor"
resource "yandex_resourcemanager_folder_iam_binding" "editor" {  
  folder_id = "b1gk23jb7ovl195p0o9n"
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.cluster-account.id}"
  ]
}

#set role "container-registry.images.puller"
resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {  
  folder_id = "b1gk23jb7ovl195p0o9n"
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.cluster-account.id}"
  ]
}

#create cluster
resource "yandex_kubernetes_cluster" "my-kubernetes-cluster" {
  name       = "my-kubernetes-cluster"
  network_id = yandex_vpc_network.my-network.id
  master {
    zonal {
      zone      = yandex_vpc_subnet.my-subnet-network.zone
      subnet_id = yandex_vpc_subnet.my-subnet-network.id
    }
  }

  #set account
  service_account_id      = yandex_iam_service_account.cluster-account.id
  node_service_account_id = yandex_iam_service_account.cluster-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

#create nodes
resource "yandex_kubernetes_node_group" "my-cluster-nodes" {
  cluster_id = yandex_kubernetes_cluster.my-kubernetes-cluster.id
   
   instance_template {
   platform_id = "standard-v3"    
      
    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.my-subnet-network.id}"]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }
   }

    scale_policy {
        auto_scale {
        min     = 1
        max     = 3
        initial = 2
        }
    }

    maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
    }
}