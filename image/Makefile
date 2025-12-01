.PHONY: build push

DOCKER_IMAGE=zed43/osm-tile-server

build:
	docker build -t ${DOCKER_IMAGE} .

push: build
	docker push ${DOCKER_IMAGE}:latest