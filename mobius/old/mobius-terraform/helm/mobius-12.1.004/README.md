
# Mobius Helm Chart

This chart is responsible to deploys mobius server in kubernetes cluster.


## Installing

To install the chart with the release name `my-release`:

```
helm install --name my-release
```

To uninstall/delete the `my-release` deployment:

```
helm delete my-release
```


## Customizing

You can customize a deployment with the variables. The following tables lists the configurable parameters of the mobius chart and their default values.

|         Parameter                            |                Description                                    |     Value                    |
|----------------------------------------------|---------------------------------------------------------------|----------------------------- |
| `image.repository`                           | Specify image docker registry                                 | `wal-artifactory.rocketsoftware.com:6564/mobius`|
| `image.tag`                                  | PostgreSQL Image tag                                          | `latest`                     |
| `image.pullPolicy`                           | Policy to pull an Image                                       | `IfNotPresent`               |
| `image.pullSecret`                           | Used to authentication based image pull from registry         | `regcred`                    |
| `fluentd.enabled`                            | Used to enable logging with fluentd                           | `false`                      |
| `fluentd.repository`                         | Name of the Docker image for fluentd                          | `wal-artifactory.rocketsoftware.com:6564/logging-service` |
| `fluentd.tag`                                | Tag of the Docker image for fluentd                           | `latest`                     |
| `fluentd.pullPolicy`                         | Policy to pull an Image                                       | `IfNotPresent`               |
| `fluentd.pullSecret`                         | Used to authentication based image pull from registry         | `regcred`                    |
| `nameOverride`                               | The name of the service to publish with                       | ``                           |
| `fullnameOverride`                           | The full name of the service to publish with                  | ``                           |
| `service.type`                               | Kubernetes Service type                                       | `ClusterIP`                  |
| `service.port`                               | port where the service is running                             | `8080`                       |
| `replicaCount`                               | To indicate how many instance should run                      | `1`                          |
| `namespace`                                  | Used to run in own namespace                                  | `1`                          |
| `master.healthProbes`                        | Flag to indicate whether health check is required or nt       | `false`                      |
| `master.healthProbesLivenessTimeout`         | Number of seconds after which the Liveness probe times out    | `1`                          |
| `master.healthProbesReadinessTimeout`        | Number of seconds after which the Readiness probe times out   | `1`                          |
| `master.healthProbeLivenessPeriodSeconds`    | How often (in seconds) to perform the Liveness probe          | `10`                         |
| `master.healthProbeReadinessPeriodSeconds`   | How often (in seconds) to perform the Readiness probe         | `10`                         |
| `master.healthProbeLivenessFailureThreshold` | When the Liveness fails,Kubernetes will try  before giving up | `3`                          |
| `master.healthProbeReadinessFailureThreshold`| When the Readiness fails, Kubernetes will try before giving up| `3`                          |
| `master.healthProbeLivenessInitialDelay`     | Number of seconds after the liveness probes are initiated.    | `1`                          |
| `master.healthProbeReadinessInitialDelay`    | Number of seconds after the Readiness probes are initiated.   | `1`                          |
| `service.annotations`                        | Annotations for service                                       | `{}`                         |
| `resources`                                  | CPU/Memory resource requests/limits                           | `{}`                         |
| `nodeSelector`                               | Node labels for pod assignment                                | `{}`                         |
| `tolerations`                                | Toleration labels for pod assignment                          | `[]`                         |
| `affinity`                                   | Node affinity                                                 | `{}`                         |
| `mobius.rds.provider`                        | Db service provider name                                      | `POSTGRESQL`                 |
| `mobius.rds.endpoint`                        | End point to connect                                          | `postgresql`                 |
| `mobius.rds.port`                            | port of the database                                          | `5432`                       |
| `mobius.rds.protocol`                        | Connection protocol                                           | `TCP`                        |
| `mobius.rds.user`                            | user name of the database                                     | `mobius_db_training`         |
| `mobius.rds.password`                        | Password of the database                                      | `***`                        |
| `mobius.rds.schema`                          | Schema name for the database                                  | `mobius_db_training`         |
| `mobius.rds.initOrUpgradeDB`                 | To Initialize or upgrade database on startup                  | `YES`                        |
| `mobius.loglevel.java`                       |  java components log level                                    | `ERROR,WARN,INFO,DEBUG`      | 
| `mobius.loglevel.ocr`                        |  OCR service log level                                        | `ERROR,WARN,INFO,DEBUG`      | 
| `mobius.loglevel.native`                     |  native components log level                                  | `ERROR,WARN,INFO,DEBUG`      | 
| `mobius.createDocumentServer`                | set value to Yes to create a document server                  | `NO`                         |
| `mobius.fts.enableIndex`                     | set value to Yes to enable Index flags                        | `NO`                         |
| `mobius.fts.localServer`                     | this vdrnet is also FTS server or not                         | `YES or NO`                  |         |
| `mobius.fts.useSolrCloud`                    | is solr deployed as cluster                                   | `YES or NO`                  |
| `mobius.fts.zookeperPort`                    | zookeper port, used when useSolrCloud is set                  |                              |
| `mobius.fts.solrPort`                        | solr port, used when useSolrCloud is NOT set                  |                              |
| `mobius.fts.collectionName`                  | index data will be stored in this collection                  |                              |
| `mobius.fts.pagecache.type`                  | page caching type (if used)                                   | `NONE or Hazelcast or Redis` |
| `mobius.mobiusDiagnostics.unusedLogPurgeInMinutes` | To configure the time period the system has to wait before removing the logs of inactive containers. | `2880 minutes` |
| `mobius.mobiusDiagnostics.initialDelayInMs`    | After server startup, job will be scheduled only after the given initial delay. | `43200000 ms` |
| `mobius.mobiusDiagnostics.fixedDelayInMs`    | Time interval between each invocation. | `3600000 ms` |
-----------------------------------------------------------------------------------------------------------------------------------------------


