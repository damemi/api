all: build
.PHONY: all

include hack/update-crds.mk

RUNTIME ?= podman
RUNTIME_IMAGE_NAME ?= openshift-api-generator

build:
	go build github.com/openshift/api/...
.PHONY: build

test:
	go test github.com/openshift/api/...
.PHONY: test

verify:
	bash -x hack/verify-deepcopy.sh
	bash -x hack/verify-protobuf.sh
	bash -x hack/verify-swagger-docs.sh
.PHONY: verify

update-deps:
	hack/update-deps.sh
.PHONY: update-deps

generate-with-container: Dockerfile.build
	$(RUNTIME) build -t $(RUNTIME_IMAGE_NAME) -f Dockerfile.build .
	$(RUNTIME) run -ti --rm -v $(PWD):/go/src/github.com/openshift/api:z -w /go/src/github.com/openshift/api $(RUNTIME_IMAGE_NAME) make generate

generate:
	hack/update-deepcopy.sh
	hack/update-protobuf.sh
	hack/update-swagger-docs.sh
.PHONY: generate

$(call update-crds,config,./config/v1)
$(call update-crds,security,./security/v1)
update-crds: update-codegen-crds-config update-codegen-crds-security
.PHONY: update-crds
verify-crds: verify-codegen-crds-config verify-codegen-crds-security
.PHONY: verify-crds
