// @see: https://druid.apache.org/docs/latest/configuration/index.html
locals {
  module_name = "druid"
  module_labels = {
    app = local.module_name
  }
}

resource "kubernetes_config_map" "config" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    DRUID_XMX = "256m"
    DRUID_XMS = "256m"
    DRUID_LOG4J = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><Configuration status=\"WARN\"><Appenders><Console name=\"Console\" target=\"SYSTEM_OUT\"><PatternLayout pattern=\"%d{ISO8601} %p [%t] %c - %m%n\"/></Console></Appenders><Loggers><Root level=\"info\"><AppenderRef ref=\"Console\"/></Root><Logger name=\"org.apache.druid.jetty.RequestLog\" additivity=\"false\" level=\"INFO\"><AppenderRef ref=\"Console\"/></Logger></Loggers></Configuration>"

    druid_extensions_loadList = "[\"druid-s3-extensions\", \"druid-kafka-indexing-service\", \"postgresql-metadata-storage\"]"
    druid_startup_logging_logProperties = "true"
    druid_zk_service_host = var.zookeeper_servers
    druid_zk_paths_base = "/druid"

    # Service discovery
    druid_selectors_indexing_serviceName = "druid/overlord"
    druid_selectors_coordinator_serviceName = "druid/coordinator"
    druid_coordinator_asOverlord_enabled = "true"
    druid_coordinator_asOverlord_overlordService = "druid/overlord"

    # Metadata storage
    druid_metadata_storage_type = "postgresql"
    druid_metadata_storage_connector_connectURI = "jdbc:postgresql://${var.postgres_endpoint}/${var.postgres_database}"
    druid_metadata_storage_connector_user = var.postgres_username
    druid_metadata_storage_connector_password = var.postgres_password

    # S3 general
    druid_s3_endpoint_url = var.minio_endpoint
    druid_s3_enablePathStyleAccess = "true"
    druid_s3_accessKey = var.minio_access_key
    druid_s3_secretKey = var.minio_secret_key

    # Deep storage
    druid_storage_type = "s3"
    druid_storage_bucket = var.minio_bucket
    druid_storage_baseKey = "druid/deep-storage"

    # For local disk (only viable in a cluster if this is a network mount):
    druid_indexer_logs_type = "s3"
    druid_indexer_logs_s3Bucket = var.minio_bucket
    druid_indexer_logs_s3Prefix = "druid/indexing-logs"

    # Storage type of double columns ommiting this will lead to index double as float at the storage layer
    druid_indexing_doubleStorage = "double"

    # Druid Web console
    druid_sql_enable = "true"
    druid_router_managementProxy_enabled = "true"

    druid_lookup_enableLookupSyncOnStartup = "false"
    druid_processing_numThreads = "2"
    druid_processing_numMergeBuffers = "2"
  }
}
