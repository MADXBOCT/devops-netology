provider "yandex" {

  zone = "ru-central1-b"
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}