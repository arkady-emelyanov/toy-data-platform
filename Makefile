.PHONT: images
images:
	# TODO: switch to $(minikube docker-env)
	@echo ">>> Make required Docker images @ Minikube"
	@echo ">>> This could take a while..."
	@echo ""

	@echo ">>> Building Edge Docker image..."
	docker build -f edge/Dockerfile edge/ -t edge:1
	@echo ""

	@echo ">>> Building Simulator Docker image..."
	docker build -f simulator/Dockerfile simulator/ -t simulator:1
	@echo ""

	@echo ">>> Done!"

## Minikube
.PHONY: minikube
minikube:
	minikube start --driver hyperkit --memory 8G

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
