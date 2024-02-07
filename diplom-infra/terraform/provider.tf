# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

#  backend "s3" {
#    endpoint   = "storage.yandexcloud.net"
#    bucket     = "my-tfstate-bucket-sg-2024"
#    region     = "ru-central1"
#    key        = "terraform.tfstate"
#    skip_region_validation      = true
#    skip_credentials_validation = true
#}

}

