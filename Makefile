IMAGE_PROXY?=registry.its.txstate.edu/mfproxy
IMAGE_NGINX?=registry.its.txstate.edu/mfproxy-nginx
DOCKERFILE_NGINX?=Dockerfile.nginx
QUAL_TAG?=qual

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

build:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Building $(IMAGE_PROXY):$(QUAL_TAG)"
	@docker build --rm -t $(IMAGE_PROXY):$(QUAL_TAG) .
	@echo "$(OK_COLOR)==>$(NO_COLOR) Building $(IMAGE_NGINX):$(QUAL_TAG)"
	@docker build --rm -f $(DOCKERFILE_NGINX) -t $(IMAGE_NGINX):$(QUAL_TAG) .

qual: build
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_PROXY):$(QUAL_TAG)"
	@docker push $(IMAGE_PROXY):$(QUAL_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_NGINX):$(QUAL_TAG)"
	@docker push $(IMAGE_NGINX):$(QUAL_TAG)
