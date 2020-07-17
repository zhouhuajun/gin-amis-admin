.PHONY: start build

NOW = $(shell date -u '+%Y%m%d%I%M%S')

APP = gin-amis-admin
SERVER_BIN = ./cmd/${APP}/${APP}
RELEASE_ROOT = release
RELEASE_SERVER = release/${APP}

all: start

build:
	@go build -ldflags "-w -s" -o $(SERVER_BIN) ./cmd/${APP}

build-darwin:
	xgo -go go-1.14.x -targets=linux/amd64 -pkg=cmd/gin-admin/main.go -dest=cmd/${APP} -out=gin-admin .

start:
	go run cmd/${APP}/main.go web -c ./configs/config.toml -m ./configs/model.conf --menu ./configs/menu.yaml --page ./configs/page_manager.yaml

swagger:
	swag init --generalInfo ./internal/app/swagger.go --output ./internal/app/swagger

wire:
	wire gen ./internal/app/injector

test:
	@go test -v $(shell go list ./...)

clean:
	rm -rf data release $(SERVER_BIN) ./internal/app/test/data ./cmd/${APP}/data

pack: build
	rm -rf $(RELEASE_ROOT) && mkdir -p $(RELEASE_SERVER)
	cp -r $(SERVER_BIN) configs web $(RELEASE_SERVER)
	cp scripts/Makefile $(RELEASE_SERVER)
	cd $(RELEASE_ROOT) && tar -zcvf $(APP).tar.gz ${APP} && sudo rm -rf ${APP}
