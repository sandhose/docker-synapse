REPOSITORY=docker.io/sandhose
IMAGE := $(REPOSITORY)/synapse
ARCHS := amd64 arm64v8 arm32v6 i386
VERSIONS := 0.34.1.1 0.34.0.1 0.34.0 0.33.9 0.33.8 0.33.7 0.33.6 0.33.5.1 0.33.5
PYTHON_VERSIONS := 3 2

DRY_RUN =

ARCH := amd64
LATEST_VERSION := 0.34.0
LATEST_PYTHON_VERSION := 3

VERSION := $(LATEST_VERSION)
PYTHON_VERSION := $(LATEST_PYTHON_VERSION)

TAG_V := v$(VERSION)
TAG_P := $(TAG_V)-py$(PYTHON_VERSION)
TAG_A := $(TAG_P)-$(ARCH)

all: $(VERSIONS:%=version-%)
	# TODO: automate this
	$(DRY_RUN) ./manifest.sh $(IMAGE):$(TAG_V)-py2 $(IMAGE):py2
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py2-amd64 $(IMAGE):py2-amd64
	$(DRY_RUN) docker push $(IMAGE):py2-amd64
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py2-arm64v8 $(IMAGE):py2-arm64v8
	$(DRY_RUN) docker push $(IMAGE):py2-arm64v8
	$(DRY_RUN) ./manifest.sh $(IMAGE):$(TAG_V)-py3 $(IMAGE):py3
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py3-amd64 $(IMAGE):py3-amd64
	$(DRY_RUN) docker push $(IMAGE):py3-amd64
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py3-arm64v8 $(IMAGE):py3-arm64v8
	$(DRY_RUN) docker push $(IMAGE):py3-arm64v8
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py3-amd64 $(IMAGE):amd64
	$(DRY_RUN) docker push $(IMAGE):amd64
	$(DRY_RUN) docker tag $(IMAGE):$(TAG_V)-py3-arm64v8 $(IMAGE):arm64v8
	$(DRY_RUN) docker push $(IMAGE):arm64v8
	$(DRY_RUN) ./manifest.sh $(IMAGE):$(TAG_V)-py3 $(IMAGE):latest

dry-run:
	@$(MAKE) DRY_RUN="@echo"

version-%:
	@$(MAKE) VERSION=$(@:version-%=%) all-pythons

all-pythons: $(PYTHON_VERSIONS:%=python-%)
	$(DRY_RUN) ./manifest.sh $(IMAGE):$(TAG_P) $(IMAGE):$(TAG_V)

python-%:
	@$(MAKE) PYTHON_VERSION=$(@:python-%=%) all-archs

all-archs: $(ARCHS:%=arch-%)
	$(DRY_RUN) ./manifest.sh $(IMAGE):$(TAG_P) $(IMAGE):$(TAG_P)

arch-%:
	@$(MAKE) ARCH=$(@:arch-%=%) image

image:
	$(DRY_RUN) docker build . \
	  -t "$(IMAGE):$(TAG_A)" \
	  --build-arg BUILD_DATE=`date -u +”%Y-%m-%dT%H:%M:%SZ”` \
	  --build-arg ARCH=$(ARCH) \
	  --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	  --build-arg SYNAPSE_VERSION=$(VERSION)
	$(DRY_RUN) docker push "$(IMAGE):$(TAG_A)"
