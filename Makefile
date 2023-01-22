# Makefile for honk docker IMAGE_NAME
# By: Fredrik Lundhag <f@mekk.com>
IMAGE_NAME := honk
BUILD_NAME := "$(IMAGE_NAME)-build"
DATA_DIR   := $(PWD)/config
DOCKER     := docker
HUB_USER   := $(USER)

.PHONY: run commit push

ifeq ($(VERSION),develop)
     ver=$("")
else
    ver=-r $(VERSION)
endif

build:
	test -n "$(VERSION)"  # Version is missing
	echo "Building version: $(VERSION)"
	$(DOCKER) run --name $(BUILD_NAME) golang:alpine ash -c "apk add --no-cache gcc make mercurial musl-dev sqlite-dev && hg clone https://humungus.tedunangst.com/r/honk /honksrc $(ver) && cd /honksrc && make && echo \"build completed.\""
	$(DOCKER) cp $(BUILD_NAME):/honksrc/honk .
	$(DOCKER) cp $(BUILD_NAME):/honksrc/views .
	$(DOCKER) rm $(BUILD_NAME)
	$(DOCKER) build --rm \
		--tag=$(IMAGE_NAME) \
		--tag=$(IMAGE_NAME):$(VERSION) .

buildonly:
	-$(DOCKER) rm $(BUILD_NAME)
	$(DOCKER) build --rm \
		--tag=$(IMAGE_NAME) \
		--tag=$(IMAGE_NAME):$(VERSION) .

run:
	$(DOCKER) \
		run \
		--rm \
		--detach \
		-e HONK_USERNAME=user \
		-e HONK_PASSWORD=password \
		-e HONK_LISTEN_ADDRESS=0.0.0.0:31337 \
		-e HONK_SERVER_NAME=honk.example.com \
		--user 1000:1000 \
		--publish=31337:31337 \
		--volume=${DATA_DIR}:/config \
		--hostname=${IMAGE_NAME} \
		--name=${IMAGE_NAME} \
		$(IMAGE_NAME)

stop:
	$(DOCKER) \
		kill ${IMAGE_NAME}

history:
	$(DOCKER) \
		history ${IMAGE_NAME}

clean:
	-$(DOCKER) rmi --force $(IMAGE_NAME)
	-$(DOCKER) rmi --force $(BUILD_NAME)
	-$(DOCKER) rm --force $(BUILD_NAME)
	-$(DOCKER) rmi --force $(HUB_USER)/$(IMAGE_NAME)
	rm honk
	rm -rf views

push:
	$(DOCKER) tag $(IMAGE_NAME) $(HUB_USER)/$(IMAGE_NAME):$(VERSION) && \
	$(DOCKER) tag ${IMAGE_NAME} ${HUB_USER}/${IMAGE_NAME}:latest && \
	$(DOCKER) push $(HUB_USER)/$(IMAGE_NAME):$(VERSION) && \
	$(DOCKER) push ${HUB_USER}/${IMAGE_NAME}:latest

commit:
	$(DOCKER) commit -m "Built version ${TAG}" -a "${USER}" ${IMAGE_NAME} ${HUB_USER}/${IMAGE_NAME}:${TAG}
