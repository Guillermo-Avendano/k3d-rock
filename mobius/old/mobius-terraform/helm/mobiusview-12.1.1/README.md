
# Mobius Helm Chart

This chart is responsible to deploys mobius view in kubernetes cluster.


## Installing

To install the chart with the release name `my-release`:

```
helm install --name mobiusview ./mobiusview --namespace tenant1
```

###Resolving database details for establishing connectivity:
Metric service uses the below configuration from values.yaml file for establishing its database connectivity.
The service can resolve the database url/port, username/password for establishing connectivity either by reading them directly from the values.yaml file or by reading them from a kube secret.

```
datasource:
  #If value for the below "databaseConnectivitySecretName" is specified, "url", "username" and "password" will be fetched from the corresponding secret keys. If value for "databaseConnectivitySecretName" is not specifed, "url", "username" and "password" values will be mapped from the below corresponding key-value pairs
  # Uncomment the below 'databaseConnectivitySecretName' and provide value for fetching corresponding secret keys.
  #databaseConnectivitySecretName:

  # Key for fetching "url" value from  the secret
  databaseUrlSecretValue: url
  # DB url with port number and schema name where the database connectivity will be established. This "url" value will be used if value for "databaseConnectivitySecretName" is not specified.
  url: jdbc:postgresql://mobius-postgresql:5432/db

  # Key for fetching username value from  the secret
  databaseUsernameSecretValue: username
  # Database username. This "username" value will be used if value for "databaseConnectivitySecretName" is not specified.
  username: postgres

  # Key for fetching password value from the secret
  databasePasswordSecretValue: password
  # Database password. This "password" value will be used if value for "databaseConnectivitySecretName" is not specified.
  password: password
```
####Database connectivity via values.yaml file :
- For this way of resolving the database details, the "databaseConnectivitySecretName" property in values.yaml file should either be left undefined or empty.
- So the values defined against the corresponding properties of "url","username" and "password" will be taken directly for establishing the connection.
- In the above case, the value for</br> <b>"url"</b> will be "jdbc:postgresql://mobius-postgresql:5432/db",</br> <b>"username"</b> will be "postgres" and </br> <b>"password"</b> will be "password"

####Database connectivity via kube secrets :
- For resolving the database details via kube secret, the "databaseConnectivitySecretName" property in values.yaml file must be defined.
- A kube secret would look like this :</br>
  <u>asg-mobius-db-resolver-secret.yaml :</u>
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: asg-mobius-db-resolver-secret
  type: Opaque
  data:
    url: amRiYzpwb3N0Z3Jlc3FsOi8vMTkyLjE2OC4wLjQ6NTQzMS9kYi1tZXRyaWM=
    username: cG9zdGdyZXM=
    password: cGFzc3dvcmQ=

  ```

- The following command is used to register the secret in the kube environment
  ```
  kubectl apply -f asg-mobius-db-resolver-secret.yaml
  ```
- The value for the property "databaseConnectivitySecretName" in the values.yaml file should be the "metadata name" given in the corresponding secret file which in this case is "asg-mobius-db-resolver-secret".
- With this type of configuration, at runtime, the database connectivity values are resolved from the properties defined under the "data" property of the secret file.
- It is to be noted that the values defined for the properties "url","username" and "password" under the "data" property in the secret are base64 encoded.


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


