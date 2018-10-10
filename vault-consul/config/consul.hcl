storage "consul" {
  address = "127.0.0.1:8500"
  advertise_addr = "http://127.0.0.1:8200"
  path = "vault"
  scheme = "http"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

# TODO needs to be set to false in production
# https://www.vaultproject.io/docs/configuration/index.html#storage
disable_mlock = true
