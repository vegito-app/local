export VEGITO_NESTOR_DIR ?= $(CURDIR)
export VEGITO_NESTOR_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-nestor
export VEGITO_NESTOR_IMAGE_VERSION ?= $(VEGITO_NESTOR_IMAGES_BASE_NAME):nestor-$(VERSION)
export VEGITO_NESTOR_IMAGE_LATEST ?= $(VEGITO_NESTOR_IMAGES_BASE_NAME):nestor-latest

vegito-nestor-container-up: vegito-nestor-container-rm
	@$(VEGITO_NESTOR_DIR)/nestor/docker-compose-up.sh
	@$(LOCAL_DOCKER_COMPOSE) logs nestor
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: vegito-nestor-container-up

LOCAL_NESTOR ?= $(LOCAL_DOCKER_COMPOSE) exec nestor

VEGITO_NESTOR_OLLAMA ?= $(LOCAL_NESTOR) ollama

VEGITO_NESTOR_OLLAMA_8B_MODELS ?= \
 qwen3:8b \
 llama3.1:8b

OLLAMA_MODELS ?= \
	$(VEGITO_NESTOR_OLLAMA_8B_MODELS:%:8b=vegito-nestor-pull-ollama-8b-%-model)

$(VEGITO_NESTOR_OLLAMA_8B_MODELS:%:8b=vegito-nestor-pull-ollama-8b-%-model):
	@echo "Pulling model $(@:vegito-nestor-pull-ollama-8b-%-model=%) with ollama..."
	@echo "Pulling model $(@:vegito-nestor-pull-ollama-8b-%-model=%) with ollama..."
	$(VEGITO_NESTOR_OLLAMA) pull $(@:vegito-nestor-pull-ollama-8b-%-model=%):8b
.PHONY: $(VEGITO_NESTOR_OLLAMA_8B_MODELS:%:8b=vegito-nestor-pull-ollama-8b-%-model)

vegito-nestor-pull-models: $(OLLAMA_MODELS)
	@echo "All models pulled successfully."
.PHONY: vegito-nestor-pull-models

vegito-nestor-ollama-server: vegito-nestor-ollama-server-up vegito-nestor-ollama-pull-models
	@echo "Ollama server is running and models are pulled."
.PHONY: vegito-nestor-ollama-server

vegito-nestor-ollama-server-up: vegito-nestor-ollama
	@echo "Starting ollama server..."
	$(VEGITO_NESTOR_OLLAMA) serve
.PHONY: vegito-nestor-ollama-server-up

VEGITO_NESTOR_DOCKER_BUILDX_BAKE ?= docker buildx bake --progress=plain \
	-f $(VEGITO_NESTOR_DIR)/docker-bake.hcl
# 	 \
	-f $(VEGITO_DOCKER_DIR)/docker-bake.hcl

VEGITO_NESTOR_DOCKER_BUILDX_BAKE_IMAGES ?= \
	nestor

$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE_IMAGES:%=vegito-%-image): vegito-docker-buildx-setup
	@$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE) --print $(@:%-image=%) 2>&1 | tee $@.make-logs
	@$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE) --load $(@:%-image=%) 2>&1 | tee -a $@.make-logs
.PHONY: $(VEGITO_NESTOR_DOCKER_BUILDX_BAKE_IMAGES:%=vegito-%-image)

$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE_IMAGES:%=vegito-%-image-ci): vegito-docker-buildx-setup
	@$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(VEGITO_NESTOR_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(VEGITO_NESTOR_DOCKER_BUILDX_BAKE_IMAGES:%=vegito-%-image-ci)