# Processing

Load test data:
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataGenerator
```

Check:
```
kafkacat -b 127.0.0.1:9092 -C -t v1.raw -f "%T\n%s\n"
```

## Beam (fix it)

DirectRunner
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pdirect-runner \
    -Dexec.args="--runner=DirectRunner --brokerUrl=127.0.0.1:9092"
```

```
mvn clean package -Pdirect-runner -DskipTests
java -cp target/processing-bundled-0.1.jar \
    org.simple.analytics.example.DataProcess \
    --runner=DirectRunner \
    --brokerUrl=127.0.0.1:9092
```

Flink
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pflink-runner \
    -Dexec.args="--runner=FlinkRunner --brokerUrl=127.0.0.1:9092"
```

Spark
```
mvn compile exec:java \
    -Dexec.mainClass=org.simple.analytics.example.DataProcess \
    -Pspark-runner \
    -Dexec.args="--runner=SparkRunner --brokerUrl=127.0.0.1:9092"
```

```
kafkacat -b 127.0.0.1:9092 -o end -C -t v1.hits
```


## Submitting to Kubernetes

### Flink
https://ci.apache.org/projects/flink/flink-docs-release-1.12/deployment/config.html#kubernetes
```
flink run-application \
	--target kubernetes-application \
	-c org.simple.analytics.example.DataProcess \
	-Dkubernetes.rest-service.exposed.type=NodePort \
	-Dkubernetes.service-account=compute-sa \
	-Dkubernetes.cluster-id=flink-job \
	-Dkubernetes.container.image=flink-job:1 \
	-Dstate.backend=filesystem \
	-Dstate.checkpoints.dir=s3p://platform/flink-checkpoints/ \
	-Dstate.backend.fs.checkpointdir=s3p://platform/flink-checkpoints/ \
	-Ds3.access-key=FEAQXFUIRMGWTMIGHSBW \
	-Ds3.secret-key=FZEKQBDZKPJGOOUXPFHM \
	-Ds3.endpoint=http://minio.storage.svc.cluster.local:9000 \
	local:///job/processing-flink-0.1.jar \
		--runner=FlinkRunner \
		--brokerUrl=kafka-0.kafka.storage.svc.cluster.local:9092 \
		--checkpointingInterval=10000
```

```
kubectl delete deployment flink-job
```

### Spark
https://spark.apache.org/docs/latest/running-on-kubernetes.html#configuration

```
spark-submit \
    --master k8s://https://127.0.0.1:55008 \
    --deploy-mode cluster \
    --name spark-job \
    --conf spark.kubernetes.context=minikube \
    --conf spark.kubernetes.container.image=spark-job:1 \
    --conf spark.executor.instances=1 \
    --conf spark.kubernetes.driver.label.app=spark \
    --conf spark.kubernetes.executor.label.app=spark \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=compute-sa \
    --class org.simple.analytics.example.DataProcess \
    local:///job/processing-spark-0.1.jar \
		--runner=SparkRunner \
		--brokerUrl=kafka-0.kafka.storage.svc.cluster.local:9092
```

```
kubectl delete pod -l app=spark
```
