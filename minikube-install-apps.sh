#!/usr/bin/env bash
set -eo pipefail

helm install edge ./charts/edge
helm install simulator ./charts/simulator

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
	-Ds3.access-key=GVHSBBJGBB \
	-Ds3.secret-key=DOSGABDPMOZBBVOQEYFQ \
	-Ds3.endpoint=http://minio.storage.svc.cluster.local:9000 \
	-Ds3.path.style.access=true \
	local:///job/processing-flink-0.1.jar \
		--runner=FlinkRunner \
		--brokerUrl=kafka-0.kafka.streaming.svc.cluster.local:9092 \
		--checkpointingInterval=10000

# kubectl exec -it -n streaming kafka-0 -- bash
# kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic v1.raw
