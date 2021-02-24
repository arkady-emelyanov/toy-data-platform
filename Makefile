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
	@echo ">>> Done!"

## Golang formatting
.PHONY: edge_fmt
edge_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: simulator_fmt
simulator_fmt:
	gofmt -d -w -s -e ./edge

.PHONY: fmt
fmt: edge_fmt simulator_fmt
