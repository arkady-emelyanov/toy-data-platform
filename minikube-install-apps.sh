#!/usr/bin/env bash
set -eo pipefail

# install applications
helm install edge ./charts/edge
helm install simulator ./charts/simulator

# run flink
#flink run-application \
#	--target kubernetes-application \
#	-c org.simple.analytics.example.DataProcess \
#	-Dkubernetes.rest-service.exposed.type=NodePort \
#	-Dkubernetes.service-account=compute-sa \
#	-Dkubernetes.cluster-id=flink-job \
#	-Dkubernetes.container.image=flink-job:1 \
#	-Dstate.backend=filesystem \
#	-Dstate.checkpoints.dir=s3p://platform/flink-checkpoints/ \
#	-Dstate.backend.fs.checkpointdir=s3p://platform/flink-checkpoints/ \
#	-Ds3.access-key=GVHSBBJGBB \
#	-Ds3.secret-key=DOSGABDPMOZBBVOQEYFQ \
#	-Ds3.endpoint=http://minio.storage.svc.cluster.local:9000 \
#	-Ds3.path.style.access=true \
#	local:///job/processing-flink-0.1.jar \
#		--runner=FlinkRunner \
#		--brokerUrl=kafka-0.kafka.streaming.svc.cluster.local:9092 \
#		--checkpointingInterval=10000

# run spark
#spark-submit \
#    --master k8s://https://127.0.0.1:55008 \
#    --deploy-mode cluster \
#    --name processing-spark \
#    --conf spark.kubernetes.context=minikube \
#    --conf spark.kubernetes.container.image=spark-job:1 \
#    --conf spark.executor.instances=1 \
#    --conf spark.kubernetes.authenticate.driver.serviceAccountName=compute-sa \
#    --class org.simple.analytics.example.DataProcess \
#    local:///job/processing-spark-0.1.jar \
#		--runner=SparkRunner \
#		--brokerUrl=kafka-0.kafka.storage.svc.cluster.local:9092


# validate everything is running smoothly:
# kubectl exec -it -n streaming kafka-0 -- bash
# kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic v1.raw
# kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic v1.hits
