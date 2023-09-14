# The content is replaced by the env variable TF_VAR_NAMESPACE in ./common/env.sh if exists
variable "NAMESPACE" { default = "mobius" }
variable "kube_config" { default = "../cluster/cluster-config.yaml"}
# MOBIUS
variable "KUBE_LOCALREGISTRY_HOST" { default = "localhost"}
variable "KUBE_LOCALREGISTRY_PORT" { default = "5000"}
variable "IMAGE_VERSION_MOBIUS" { default = "12.1.004"}
variable "IMAGE_NAME_MOBIUS" { default = "mobius-server"}
variable "IMAGE_VERSION_MOBIUSVIEW" { default = "12.1.1"}
variable "IMAGE_NAME_MOBIUSVIEW" { default = "mobius-view"}
variable "IMAGE_VERSION_EVENTANALYTICS" { default = "1.3.8"}
variable "IMAGE_NAME_EVENTANALYTICS" { default = "eventanalytics"}
variable "POSTGRESQL_USERNAME" { default = "mobius"}
variable "POSTGRESQL_PASSWORD" { default = "password"}
variable "POSTGRESQL_DBNAME_MOBIUSVIEW" { default = "mobiusview12"}
variable "POSTGRESQL_DBNAME_MOBIUS" { default = "mobiusserver12"}
variable "POSTGRESQL_DBNAME_EVENTANALYTICS" { default = "eventanalytics"}
variable "POSTGRESQL_HOST" { default = "postgresql.shared.svc.cluster.local"}
variable "POSTGRESQL_PORT" { default = "5432"}
variable "RDSPROVIDER" { default = "POSTGRESQL"}
variable "ENABLEINDEX" { default = "YES"}
variable "MOBIUS_FTS_HOST" { default = "elasticsearch-master.shared"}
variable "MOBIUS_FTS_PORT" { default = "9200"}
variable "MOBIUS_FTS_INDEX_NAME" { default = "mobius12"}
variable "KAFKA_BOOTSTRAP_URL" { default = "kafka.shared.svc.cluster.local:9092"}

variable "DEFAULT_SSO_KEY" { default = "ADASDFASDFXGGEG25585"}
variable "MOBIUS_ADMIN_USER" { default = "admin"}
variable "MOBIUS_ADMIN_GROUP" { default = "mobiusadmin"}

variable "mobius_storageClassName" { default = "local-path"}
variable "mobius_persistentVolume_claimName" { default = "pvc-mobius12-efs"}
variable "mobius_mobiusDiagnostics_persistentVolume_claimName" { default = "pvc-mobius12-diagnose"}

# MOBIUSVIEW
variable "MOBIUS_LICENSE" { default = "license"}
variable "MOBIUS_VIEW_URL" { default = "mobius12.local.net"}
variable "MOBIUS_VIEW_URL2" { default = "mobius12.rocketsoftware.net"}
variable "MOBIUS_VIEW_TLS_SECRET" { default = "mobius-tls-secret"}
variable "MOBIUS_HOST" { default = "mobius12"}
variable "MOBIUS_PORT" { default = "8080"}

variable "mobiusview_master_persistence_claimName" { default = "pvc-mobiusview12-storage"}
variable "mobiusview_master_mobiusViewDiagnostics_persistentVolume_claimName" { default = "pvc-mobiusview12-diag"}
variable "mobiusview_master_presentations_persistence_claimName" { default = "pvc-mobiusview12-pres"}
variable "mobiusview_datasource_databaseConnectivitySecretName" { default = "mobiusview-server-secrets"}
variable "mobiusview_datasource_databaseUrlSecretValue" { default = "url"}
variable "mobiusview_datasource_databaseUsernameSecretValue" { default = "username"}
variable "mobiusview_datasource_databasePasswordSecretValue" { default = "password"}
variable "mobiusview_service_port" { default = "8080"}
