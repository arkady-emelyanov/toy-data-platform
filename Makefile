.PHONT: make_images
make_images:
	@echo "Make required Docker images @ Minikube"
	@echo "This could take a while..."


## Golang formatting
.PHONY: edge_fmt
edge_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: simulator_fmt
simulator_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: fmt
fmt: edge_fmt simulator_fmt
