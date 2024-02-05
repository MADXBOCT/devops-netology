provider "yandex" {

  zone = "ru-central1-b"
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "lamp"
}

resource "yandex_iam_service_account" "sa" {
  name = "robot"
}

resource "yandex_iam_service_account" "sa2" {
  name = "robot2"
}

// Assigning roles to the service account
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1gqdc5g77am21vlmc7a"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "comp-editor" {
  folder_id = "b1gqdc5g77am21vlmc7a"
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa2.id}"
}

// Creating a static access key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Creating a bucket using the key
resource "yandex_storage_bucket" "sgudimov-20240205" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "sgudimov-20240205"

  anonymous_access_flags {
    read = true
    list = false
  }

}