IMAGE_PROXY?=registry.its.txstate.edu/mfproxy
IMAGE_NGINX?=registry.its.txstate.edu/mfproxy-nginx
DOCKERFILE_NGINX?=Dockerfile.nginx
QUAL_TAG?=qual
PROD_TAG?=prod
SAVE_TAG?=$(shell date +"%Y-%m-%d")-$(shell git rev-parse --short HEAD)

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

save-prod:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_PROXY):$(PROD_TAG)"
	@docker pull $(IMAGE_PROXY):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_NGINX):$(PROD_TAG)"
	@docker pull $(IMAGE_NGINX):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Tagging $(IMAGE_PROXY):$(PROD_TAG) -> $(IMAGE_PROXY):$(SAVE_TAG)"
	@docker tag $(IMAGE_PROXY):$(PROD_TAG) $(IMAGE_PROXY):$(SAVE_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Tagging $(IMAGE_NGINX):$(PROD_TAG) -> $(IMAGE_NGINX):$(SAVE_TAG)"
	@docker tag $(IMAGE_NGINX):$(PROD_TAG) $(IMAGE_NGINX):$(SAVE_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_PROXY):$(SAVE_TAG)"
	@docker push $(IMAGE_PROXY):$(SAVE_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_NGINX):$(SAVE_TAG)"
	@docker push $(IMAGE_NGINX):$(SAVE_TAG)

prod: save-prod
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_PROXY):$(QUAL_TAG)"
	@docker pull $(IMAGE_PROXY):$(QUAL_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_NGINX):$(QUAL_TAG)"
	@docker pull $(IMAGE_NGINX):$(QUAL_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_PROXY):$(PROD_TAG)"
	@docker pull $(IMAGE_PROXY):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pulling $(IMAGE_NGINX):$(PROD_TAG)"
	@docker pull $(IMAGE_NGINX):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Tagging $(IMAGE_PROXY):$(QUAL_TAG) -> $(IMAGE_PROXY):$(PROD_TAG)"
	@docker tag $(IMAGE_PROXY):$(QUAL_TAG) $(IMAGE_PROXY):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Tagging $(IMAGE_NGINX):$(QUAL_TAG) -> $(IMAGE_NGINX):$(PROD_TAG)"
	@docker tag $(IMAGE_NGINX):$(QUAL_TAG) $(IMAGE_NGINX):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_PROXY):$(PROD_TAG)"
	@docker push $(IMAGE_PROXY):$(PROD_TAG)
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(IMAGE_NGINX):$(PROD_TAG)"
	@docker push $(IMAGE_NGINX):$(PROD_TAG)

tag:
	@echo $(SAVE_TAG)
