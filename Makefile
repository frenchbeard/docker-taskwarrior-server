# Largely inspired from sameersbn/docker-gitlab's Makefile
NAME = $(USER)/taskd
VERSION = 0.1.0

.PHONY: all build test tag_latest release

all: build

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build        - build the taskd image"
	@echo "   2. make tag_latest   - tag the latest build \"latest\""
	@echo "   3. make release      - release the latest build on docker hub"
	@echo "   4. make quickstart   - start taskd"
	@echo "   5. make stop         - stop taskd"
	@echo "   6. make logs         - view logs"
	@echo "   7. make purge        - stop and remove the container"

build:
	docker build -t $(NAME):$(VERSION) --rm .

build_nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: build tag_latest
	docker push $(NAME)

quickstart:
	@echo "Starting taskd container..."
	@docker run --name='taskd-demo' -d \
		--publish=53589:53589 $(NAME):$(VERSION)
	@echo "Please be patient. This could take a while..."
	@echo "taskd will be available at http://localhost:53589"
	@echo "Type 'make logs' for the logs"

stop:
	@echo "Stopping taskd..."
	@docker stop taskd-demo >/dev/null

purge: stop
	@echo "Removing stopped containers..."
	@docker rm -v taskd-demo >/dev/null

logs:
	@docker logs -f taskd-demo
