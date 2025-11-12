ui = true

api_addr = "http://0.0.0.0:3000"

storage "file" {
  path = "/home/user/app/openbao-data"
}

listener "tcp" {
  address     = "0.0.0.0:3000" 
  tls_disable = true 
}