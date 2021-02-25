.PHONT: images
images:
	@eval $$(minikube docker-env) \
	@echo ">>> Make required Docker images @ Minikube"
	@echo ">>> This could take a while..."
	@echo ">>> Building Edge Docker image..."
	docker build -f edge/Dockerfile edge/ -t edge:1
	@echo ">>> Building Simulator Docker image..."
	docker build -f simulator/Dockerfile simulator/ -t simulator:1
	@echo ">>> Building Flink jar image"
	@cd processing && mvn clean package -Pflink-runner -DskipTests
	docker build -f processing/Dockerfile.flink processing/ -t flink-app:1
	@echo ">>> Done!"

## Minikube
.PHONY: minikube
minikube:
	minikube start --memory 8G --cpus=4 --driver docker

## Terraform
.PHONY: tfinit
tfinit:
	cd terraform && terraform init

.PHONY: tfapply
tfapply:
	cd terraform && terraform apply

.PHONY: tfdestroy
tfdestroy:
	cd terraform && terraform destroy

## Golang formatting
.PHONY: edge_fmt
edge_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: simulator_fmt
simulator_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: fmt
fmt: edge_fmt simulator_fmt
