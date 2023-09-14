############### HELM FOR EVENTANALYTICS #############
resource "helm_release" "eventanalytics" {
  name             = "eventanalytics"
  chart            = "${path.module}/helm/eventanalytics-1.3.8"
  namespace        = var.NAMESPACE
  create_namespace = true


 set {
    name  = "namespace"
    value = var.NAMESPACE
  }
  
 set {
    name  = "image.repository"
    value = "${var.KUBE_LOCALREGISTRY_HOST}:${var.KUBE_LOCALREGISTRY_PORT}/${var.IMAGE_NAME_EVENTANALYTICS}"
  }

  set {
    name  = "image.tag"
    value = var.IMAGE_VERSION_EVENTANALYTICS
  }
  set {
    name  = "datasource.url"
    value = "jdbc:postgresql://${var.POSTGRESQL_HOST}:${var.POSTGRESQL_PORT}/${var.POSTGRESQL_DBNAME_EVENTANALYTICS}"
     } 
  set {
    name  = "datasource.username"
    value = var.POSTGRESQL_USERNAME
     } 
  set {
    name  = "datasource.password"
    value = var.POSTGRESQL_PASSWORD
     }
  set {
    name  = "spring.kafka.bootstrap.servers"
    value = var.KAFKA_BOOTSTRAP_URL
     }     

}
############### HELM FOR MOBIUS #############
resource "helm_release" "mobius12" {
  name             = "mobius12"
  chart            = "${path.module}/helm/mobius-12.1.004"
  namespace        = var.NAMESPACE
  create_namespace = true


 set {
    name  = "namespace"
    value = var.NAMESPACE
  }
 set {
    name  = "image.repository"
    value = "${var.KUBE_LOCALREGISTRY_HOST}:${var.KUBE_LOCALREGISTRY_PORT}/${var.IMAGE_NAME_MOBIUS}"
  }

  set {
    name  = "image.tag"
    value = var.IMAGE_VERSION_MOBIUS
  }

  set {
    name  = "mobius.rds.provider"
    value = var.RDSPROVIDER
  }

  set {
    name  = "mobius.rds.endpoint"
    value = var.POSTGRESQL_HOST
  }
  set {
    name  = "mobius.rds.port"
    value = var.POSTGRESQL_PORT
  }

  set {
    name  = "mobius.rds.user"
    value = var.POSTGRESQL_USERNAME
  }

  set {
    name  = "mobius.rds.password"
    value = var.POSTGRESQL_PASSWORD
  }

  set {
    name  = "mobius.rds.schema"
    value = var.POSTGRESQL_DBNAME_MOBIUS
  }
  set {
    name  = "mobius.persistentVolume.enabled"
    value = "true"
  }
  set {
    name  = "mobius.persistentVolume.claimName"
    value = var.mobius_persistentVolume_claimName
  }
  set {
    name  = "mobius.mobiusDiagnostics.persistentVolume.enabled"
    value = "true"
  }
  set {
    name  = "mobius.mobiusDiagnostics.persistentVolume.claimName"
    value = var.mobius_mobiusDiagnostics_persistentVolume_claimName
  }
  set {
    name  = "mobius.createDocumentServer"
    value = "YES"
  }

  set {
    name  = "mobius.fts.enabled"
    value = var.ENABLEINDEX
     }
  set {
    name  = "mobius.fts.engineType"
    value = "elasticsearch"
     }
        
  set {
    name  = "mobius.fts.host"
    value = var.MOBIUS_FTS_HOST
     }
   
  set {
    name  = "mobius.fts.port"
    value = var.MOBIUS_FTS_PORT
     }        
  set {
    name  = "mobius.fts.serverProtocol"
    value = "HTTP"
     } 
  set {
    name  = "mobius.fts.indexName"
    value = var.MOBIUS_FTS_INDEX_NAME
     } 

  set {
    name  = "mobius.topic.export.url"
    value = "jdbc:postgresql://${var.POSTGRESQL_HOST}:${var.POSTGRESQL_PORT}/${var.POSTGRESQL_DBNAME_EVENTANALYTICS}"
     } 
  set {
    name  = "mobius.topic.export.user"
    value = var.POSTGRESQL_USERNAME
     } 
  set {
    name  = "mobius.topic.export.password"
    value = var.POSTGRESQL_PASSWORD
     } 
  set {
    name  = "mobius.topic.export.driver"
    value = "org.postgresql.Driver"
     }    
  set {
    name  = "storageClassName"
    value = var.mobius_storageClassName
  }

  set {
    name  = "mobius.admin.user"
    value = var.MOBIUS_ADMIN_USER
  }

  set {
    name  = "mobius.admin.group"
    value = var.MOBIUS_ADMIN_GROUP
  }

  set {
    name  = "spring.kafka.bootstrap.servers"
    value = var.KAFKA_BOOTSTRAP_URL
     } 
 

  set {
    name  = "mobius.clustering.kubernetes.namespace"
    value = var.NAMESPACE
  }

}  

############### HELM FOR MOBIUS-VIEW #############
resource "helm_release" "mobiusview12" {
  name             = "mobiusview12"
  chart            = "${path.module}/helm/mobiusview-12.1.1"
  namespace        = var.NAMESPACE
  create_namespace = true
 set {
    name  = "namespace"
    value = var.NAMESPACE
  }
 set {
    name  = "image.repository"
    value = "${var.KUBE_LOCALREGISTRY_HOST}:${var.KUBE_LOCALREGISTRY_PORT}/${var.IMAGE_NAME_MOBIUSVIEW}"
  }

  set {
    name  = "image.tag"
    value = var.IMAGE_VERSION_MOBIUSVIEW
  }
    set {
    name  = "service.port"
    value = var.mobiusview_service_port
  }
  #---------------
  set {
    name  = "master.persistence.claimName"
    value = var.mobiusview_master_persistence_claimName
  }
   set {
    name  = "master.persistence.enabled"
    value = "true"
  }
  #---------------
  set {
    name  = "master.mobiusViewDiagnostics.persistentVolume.claimName"
    value = var.mobiusview_master_mobiusViewDiagnostics_persistentVolume_claimName
  }
    set {
    name  = "master.mobiusViewDiagnostics.persistentVolume.enabled"
    value = "true"
  }
   #---------------
  set {
    name  = "master.presentations.persistence.claimName"
    value = var.mobiusview_master_presentations_persistence_claimName
  }
  set {
    name  = "master.presentations.persistence.enabled"
    value = "true"
  }
   #---------------

  set {
    name  = "datasource.databaseConnectivitySecretName"
    value = var.mobiusview_datasource_databaseConnectivitySecretName
  }

  set {
    name  = "datasource.databaseUrlSecretValue"
    value = var.mobiusview_datasource_databaseUrlSecretValue
  }

   set {
    name  = "datasource.databaseUsernameSecretValue"
    value = var.mobiusview_datasource_databaseUsernameSecretValue
  }

     set {
    name  = "datasource.databasePasswordSecretValue"
    value = var.mobiusview_datasource_databasePasswordSecretValue
  }
  #---------------
  set {
    name  = "spring.kafka.bootstrap.servers"
    value = var.KAFKA_BOOTSTRAP_URL
  }

  set {
    name  = "initRepository.enabled"
    value = "true"
  }

  set {
    name  = "initRepository.host"
    value = var.MOBIUS_HOST
  }

  set {
    name  = "initRepository.port"
    value = var.MOBIUS_PORT
  }


 values = [
    jsonencode({
      ingress = {
        enabled = true
        className = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/rewrite-target"             = "/mobius$1"
          "nginx.ingress.kubernetes.io/proxy-body-size"            = "32m"
          "nginx.ingress.kubernetes.io/affinity"                   = "cookie"
          "nginx.ingress.kubernetes.io/session-cookie-name"        = "session-cookie"
          "nginx.ingress.kubernetes.io/session-cookie-expires"     = "172800"
          "nginx.ingress.kubernetes.io/session-cookie-max-age"     = "172800"
          "nginx.ingress.kubernetes.io/ssl-redirect"               = "false"
          "nginx.ingress.kubernetes.io/affinity-mode"              = "persistent"
          "nginx.ingress.kubernetes.io/session-cookie-change-on-failure" = "false"
          "nginx.ingress.kubernetes.io/session-cookie-hash"        = "sha1"
          "nginx.ingress.kubernetes.io/session-cookie-path"        = "/mobius"
          "nginx.ingress.kubernetes.io/proxy-buffer-size"          = "8k"
        }
        hosts = [
          {
            host  = var.MOBIUS_VIEW_URL # new host
            paths = [
              {
                path     = "/mobius(.*)$"
                pathType = "ImplementationSpecific"
              }
            ]
          },
          {
            host  = var.MOBIUS_VIEW_URL2 # new host
            paths = [
              {
                path     = "/mobius(.*)$"
                pathType = "ImplementationSpecific"
              }
            ]
          }          
        ]
        /*
        tls = [
        {
          secretName = var.MOBIUS_VIEW_TLS_SECRET
          hosts = [ var.MOBIUS_VIEW_URL ]
        }
      ]
      */
      }
    })
  ]
}
