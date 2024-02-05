resource "yandex_storage_object" "test-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "sgudimov-20240205"
  key        = "picture.jpg"
  source     = "e38_04sshd_1600.jpg"
}

# https://storage.yandexcloud.net/sgudimov-20240205/picture.jpg