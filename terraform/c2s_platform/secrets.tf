# vim: ts=4:sw=4:et:ft=hcl

resource "random_string" "rabbit_password" {
  length = 17
  special = false
}

resource "random_string" "aries_http_search_user_password" {
  length = 17
  special = false
}

resource "random_string" "aries_http_command_user_password" {
  length = 17
  special = false
}

resource "random_string" "cortex_http_search_user_password" {
  length = 17
  special = false
}

resource "random_string" "orion_http_search_user_password" {
  length = 17
  special = false
}
