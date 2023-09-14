
# Mobius Helm Chart

This chart is responsible to deploys mobius view in kubernetes cluster.


## Installing

To install the chart with the release name `my-release`:

```
helm install --name mobiusview ./mobiusview --namespace tenant1
```

To uninstall/delete the `my-release` deployment:

```
helm delete --purge mobiusview 
```


## Customizing

You can customize a deployment with the variables. The following tables lists the configurable parameters of the mobius chart and their default values.

|         Parameter                     	   |                Description                                    |     Value                    |   
|----------------------------------------------|---------------------------------------------------------------|----------------------------- |
| `image.repository`                    	   | Specify image docker registry                      		   | `docker-local.bin-na.asg.com/mobius-view`|
| `image.tag`                           	   | PostgreSQL Image tag                               		   | `latest`                     |
| `image.pullPolicy`                    	   | Policy to pull an Image									   | `IfNotPresent`				  |
| `image.pullSecret`                    	   | Used to authentication based image pull from registry  	   | `regcred`					  |
| `fluentd.enabled`                    	       | Used to enable logging with fluentd                    	   | `false`					  |
| `fluentd.repository`                    	       | Name of the Docker image for fluentd                    	   | `docker-local.bin-na.asg.com/logging-service` |
| `fluentd.tag`                      	       | Tag of the Docker image for fluentd                    	   | `latest`					  |
| `fluentd.pullPolicy`                    	   | Policy to pull an Image									   | `IfNotPresent`				  |
| `fluentd.pullSecret`                    	   | Used to authentication based image pull from registry  	   | `regcred`					  |
| `nameOverride`                        	   | The name of the service to publish with            		   | ``                           |
| `fullnameOverride`                    	   | The full name of the service to publish with       		   | ``                           |
| `service.type`                        	   | Kubernetes Service type                            		   | `ClusterIP`                  |
| `service.port`                        	   | port where the service is running                  		   | `8080`                       |
| `replicaCount`                        	   | To indicate how many instance should run					   | `1`						  |
| `namespace`                                  | Used to run in own namespace								   | `1`						  |
| `master.healthProbes`                        | Flag to indicate whether health check is required or not	   | `false`					  |
| `master.healthProbesLivenessTimeout`         | Number of seconds after which the Liveness probe times out    | `1`						  |
| `master.healthProbesReadinessTimeout`        | Number of seconds after which the Readiness probe times out   | `1`						  |
| `master.healthProbeLivenessPeriodSeconds`    | How often (in seconds) to perform the Liveness probe          | `10`					      |
| `master.healthProbeReadinessPeriodSeconds`   | How often (in seconds) to perform the Readiness probe		   | `10`    					  |
| `master.healthProbeLivenessFailureThreshold` | When the Liveness fails,Kubernetes will try  before giving up | `3`						  |
| `master.healthProbeReadinessFailureThreshold`| When the Readiness fails, Kubernetes will try before giving up| `3`						  |
| `master.healthProbeLivenessInitialDelay`     | Number of seconds after the liveness probes are initiated.    | `1`                          |
| `master.healthProbeReadinessInitialDelay`    | Number of seconds after the Readiness probes are initiated.   | `1`						  |
| `service.annotations`                		   | Annotations for service                 					   | `{}`                         |                                                                              
| `resources`                          	       | CPU/Memory resource requests/limits                           | `{}`                         |                             
| `nodeSelector`                       		   | Node labels for pod assignment                                | `{}`                         |                            
| `tolerations`                        		   | Toleration labels for pod assignment                          | `[]`                         |                             
| `affinity`                           		   | Node affinity                                                 | `{}`                         |                            
| `rdsprovider`                                | Db service provider name 									   | `POSTGRESQL`                 | 
| `rdscreatenewdb`							   | To create new DB or not 									   | `YES`                        |
| `rdsusername`                                | user name of the database 									   | `mobius_db_training`         |                    
| `rdspassword`								   | Password of the database 									   | `***`                        |
| `rdsendpoint`								   | End point to connect 									       | `postgresql`                 |
| `rdsport`									   | port of the database 									       | `5432`                 	  |
| `rdsproto`								   | Port connection to 									       | `TCP`                        | 
| `mobiusschemaname`						   | Schema name for the database 								   | `mobius_db_training`         |
| `mobiusschemapassword`					   | Password for the schema if any 							   | `***`                        |
| `master.mobiusDiagnostics.unusedLogPurgeInMinutes` | To configure the time period the system has to wait before removing the logs of inactive containers. | `2880 minutes` |
| `master.mobiusDiagnostics.initialDelayInMs`    | After server startup, job will be scheduled only after the given initial delay. | `43200000 ms` |
| `master.mobiusDiagnostics.fixedDelayInMs`    | Time interval between each invocation. | `3600000 ms` |
| `dependson`                                  | A comma separated list of URLs that point to the heath check of the services which need to be running before MobiusView can start|  | 
| `master.presentations.persistence.enabled`    | Value to specify if persestance is needed for presentation. | `false` |
| `master.presentations.persistence.claimName`    | The claim name to use for presentation persistence. | `mobius-pv-presentation-images-claim-dev` |
-----------------------------------------------------------------------------------------------------------------------------------------------


