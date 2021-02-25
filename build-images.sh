#!/usr/bin/env bash
set -eo pipefail

echo ">>> Building platform Docker images @ Minikube"
echo ">>> This could take a while..."
eval $(minikube docker-env --shell bash)

echo ">>> Building Edge Docker image..."
docker build -f edge/Dockerfile edge/ -t edge:1

echo ">>> Building Simulator Docker image..."
docker build -f simulator/Dockerfile simulator/ -t simulator:1

echo ">>> Building Job images..."
cd processing/

echo ">>> Building Flink job image"
mvn clean package -Pflink-runner -DskipTests
docker build -f Dockerfile.flink . -t flink-job:1

echo ">>> Building Spark job image"
mvn clean package -Pspark-runner -DskipTests
docker build -f Dockerfile.spark . -t spark-job:1

cd ..
echo ">>> Done!"
