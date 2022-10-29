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
  token     = var.yc_token  #variable.tf
  cloud_id  = "b1gqokp4g93bklg01717"
  folder_id = "b1gk23jb7ovl195p0o9n"
  zone      = "ru-central1-a"
}
 
// create service account
resource "yandex_iam_service_account" "bucket-user" {
  name      = "bucket-user"
}

// set role to service account
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-user.id}"
  folder_id = "b1gk23jb7ovl195p0o9n"
}

// create static key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-user.id
  description        = "static access key for object storage"
}

// create bucket
resource "yandex_storage_bucket" "momo-store-s3-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "momo-store-s3-bucket"
 
  lifecycle_rule {
      id      = "log"
      enabled = true
      prefix = "log/"
    
      transition  {
      days    = 30
      storage_class = "COLD"
      }

      expiration {
      days = 90
      }
  }

  lifecycle_rule {
    id  = "tmp"
    prefix = "tmp/"
    enabled =  true

    expiration {
      date = "2022-12-31"
    }
  }

}  