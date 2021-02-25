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
