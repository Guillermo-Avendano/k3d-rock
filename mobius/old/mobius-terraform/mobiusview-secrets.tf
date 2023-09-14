############### SECRETS FOR MOBIUS-VIEW #############
locals {
  mobius_tls_key = "${path.module}/cert/base64_${var.MOBIUS_VIEW_URL}.key"
  mobius_tls_crt = "${path.module}/cert/base64_${var.MOBIUS_VIEW_URL}.crt"
}

resource "kubernetes_secret" "mobiusview-server-secrets" {
  metadata {
    name = var.mobiusview_datasource_databaseConnectivitySecretName
    namespace  = var.NAMESPACE
  }
  data = {
    url      = "jdbc:postgresql://${var.POSTGRESQL_HOST}:${var.POSTGRESQL_PORT}/${var.POSTGRESQL_DBNAME_MOBIUSVIEW}"
    username = var.POSTGRESQL_USERNAME
    password = var.POSTGRESQL_PASSWORD
  }
}

resource "kubernetes_secret" "mobiusview_license" {
  metadata {
    name = "mobius-license"
    namespace  = var.NAMESPACE
  }
  data = {
    license = var.MOBIUS_LICENSE
  }
}


resource "kubernetes_secret" "mobius-tls-secret" {
  metadata {
    name = var.MOBIUS_VIEW_TLS_SECRET
    namespace  = var.NAMESPACE
  }
  
  data = {
    "tls.crt" = file(local.mobius_tls_crt)
    "tls.key" = file(local.mobius_tls_key)
  }

  type = "kubernetes.io/tls"
 
}
