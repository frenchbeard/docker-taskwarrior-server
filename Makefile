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
	@echo '   2. make tag_latest   - tag the latest build "latest"'
	@echo "   3. make release      - release the latest build on docker hub"
	@echo "   4. make test         - run testing local session"
	@echo '                          -> mounts to $(shell pwd)/taskd_home'
	@echo '                          -> "resets" folder hierarchy and permissions if required'
	@echo '                          -> is removed when stopped'
	@echo "   5. make stop         - stop taskd"
	@echo "   6. make logs         - view logs"
	@echo "--"
	@echo "For production, a docker-compose.yml is provided."

build:
	docker build -t $(NAME):$(VERSION) --rm .

build_nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: build tag_latest
	docker push $(NAME)

test: build
	./test.sh
stop:
	@echo "Stopping taskd..."
	@docker stop taskd-demo >/dev/null

purge: stop
	@echo "Removing stopped containers..."
	@docker rm -v taskd-demo >/dev/null

logs:
	@docker logs -f taskd-demo
