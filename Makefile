BASE_IMAGE=coredns/coredns
IMAGE=gathersrv-demo
IMAGE_VERSION=latest
COREDNS_SRC_PATH=${PWD}/coredns-source
COREDNS_VERSION=v1.11.1
DOCKER_PATH=${PWD}/docker
DNS_PORT=53
METRICS_PORT=9253
UPSTREAM=/etc/resolv.conf
GOVERSION=1.22
GATHER_SRV_PLUGIN_VERSION=v1.0.2

.PHONY: version rebuild-docker-only run bash clean

all: .build

clean:
	rm -f .build $(DOCKER_PATH)/coredns
	rm -rf $(COREDNS_SRC_PATH)

.build: $(DOCKER_PATH)/coredns version
	cd $(DOCKER_PATH) && docker build --build-arg base=$(BASE_IMAGE) -t $(FULLIMAGE) .

$(DOCKER_PATH)/coredns: $(COREDNS_SRC_PATH)/plugin-original.cfg
	docker run --rm -v $(COREDNS_SRC_PATH):/v -w /v golang:$(GOVERSION) /bin/bash -c "go get github.com/ziollek/gathersrv@${GATHER_SRV_PLUGIN_VERSION};make GITCOMMIT=$(COREDNS_VERSION) BUILDOPTS='-v -buildvcs=false'"
	mv $(COREDNS_SRC_PATH)/coredns $(DOCKER_PATH)/coredns

$(COREDNS_SRC_PATH)/plugin-original.cfg: $(COREDNS_SRC_PATH)
	# put gathersrv after prometheus, cancel in order to accept timeouts set by cancel plugin and do not count sub-queries as separate requests
	cat $(COREDNS_SRC_PATH)/plugin.cfg | grep -v gathersrv | sed "s#prometheus:metrics#prometheus:metrics\ngathersrv:github.com/ziollek/gathersrv#" > $(COREDNS_SRC_PATH)/plugin-original.cfg
	cp $(COREDNS_SRC_PATH)/plugin-original.cfg $(COREDNS_SRC_PATH)/plugin.cfg

$(COREDNS_SRC_PATH):
	git clone --branch $(COREDNS_VERSION) --depth 1 https://github.com/coredns/coredns $(COREDNS_SRC_PATH)

version:
	$(eval FULLIMAGE := $(IMAGE):$(IMAGE_VERSION))

rebuild-docker-only: version
	cd $(DOCKER_PATH) && docker build -t $(FULLIMAGE) .

run: version
	docker run -p $(DNS_PORT):$(DNS_PORT)/udp -p $(DNS_PORT):$(DNS_PORT)/tcp -p $(METRICS_PORT):$(METRICS_PORT)/tcp -it -e DNS_PORT=$(DNS_PORT) -e METRICS_PORT=$(METRICS_PORT) -e UPSTREAM=$(UPSTREAM) --rm $(FULLIMAGE)

exec: version
	docker run -p $(DNS_PORT):$(DNS_PORT)/udp -p $(DNS_PORT):$(DNS_PORT)/tcp -p $(METRICS_PORT):$(METRICS_PORT)/tcp -it -e DNS_PORT=$(DNS_PORT) -e METRICS_PORT=$(METRICS_PORT) -e UPSTREAM=$(UPSTREAM) --rm $(FULLIMAGE) -conf /opt/Coredns
