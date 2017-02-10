KUBE_ZK_VERSION ?= 0.1.0
ZK_VERSION ?= 3.4.5

REPOSITORY ?= everpeace/kube-zookeeper
TAG ?= $(ZK_VERSION)-$(KUBE_ZK_VERSION)
IMAGE ?= $(REPOSITORY):$(TAG)
ALIAS ?= $(REPOSITORY):$(ZK_VERSION)
LATEST ?= $(REPOSITORY):latest

BUILD_ROOT ?= build/$(TAG)
DOCKERFILE ?= $(BUILD_ROOT)/Dockerfile
ZOO_CFG ?= $(BUILD_ROOT)/zoo.cfg
RUN_SH ?= $(BUILD_ROOT)/config-and-run.sh
DOCKER_CACHE ?= docker-cache
SAVED_IMAGE ?= $(DOCKER_CACHE)/image-$(ZK_VERSION).tar

.PHONY: build
build: $(DOCKERFILE) $(ZOO_CFG) $(RUN_SH)
	cd $(BUILD_ROOT) && docker build -t $(IMAGE) . && docker tag $(IMAGE) $(ALIAS)

.PHONY: clean
clean:
	rm -rf $(BUILD_ROOT)

publish:
	docker tag $(IMAGE) $(LATEST) && docker push $(IMAGE) && docker push $(ALIAS) && docker push $(LATEST)

$(DOCKERFILE): $(BUILD_ROOT)
	sed 's/%%ZK_VERSION%%/'"$(ZK_VERSION)"'/g;' Dockerfile.template > $(DOCKERFILE)

$(ZOO_CFG): $(BUILD_ROOT)
	cp zoo.cfg $(ZOO_CFG)

$(RUN_SH): $(BUILD_ROOT)
	cp config-and-run.sh $(RUN_SH)

$(BUILD_ROOT):
	mkdir -p $(BUILD_ROOT)

travis-env:
	travis env set DOCKER_EMAIL $(DOCKER_EMAIL)
	travis env set DOCKER_USERNAME $(DOCKER_USERNAME)
	travis env set DOCKER_PASSWORD $(DOCKER_PASSWORD)

test:
	@echo There are no tests available for now. Skipping

save-docker-cache: $(DOCKER_CACHE)
	docker save $(IMAGE) $(shell docker history -q $(IMAGE) | tail -n +2 | grep -v \<missing\> | tr '\n' ' ') > $(SAVED_IMAGE)
	ls -lah $(DOCKER_CACHE)

load-docker-cache: $(DOCKER_CACHE)
	if [ -e $(SAVED_IMAGE) ]; then docker load < $(SAVED_IMAGE); fi

$(DOCKER_CACHE):
	mkdir -p $(DOCKER_CACHE)

docker-run: DOCKER_CMD ?=
docker-run:
	docker run --rm -it $(IMAGE) $(DOCKER_CMD)
