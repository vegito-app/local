export VEGITO_NESTOR_DIR ?= $(CURDIR)
export VEGITO_NESTOR_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-nestor
export VEGITO_NESTOR_IMAGE_VERSION ?= $(VEGITO_NESTOR_IMAGES_BASE_NAME):nestor-$(VERSION)
export VEGITO_NESTOR_IMAGE_LATEST ?= $(VEGITO_NESTOR_IMAGES_BASE_NAME):nestor-latest

local-nestor-container-up: local-nestor-container-rm
	@${VEGITO_NESTOR_DIR}/container-up.sh
	@$(LOCAL_DOCKER_COMPOSE) logs nestor
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-nestor-container-up

LOCAL_NESTOR ?= $(LOCAL_DOCKER_COMPOSE) exec nestor

LOCAL_NESTOR_OLLAMA ?= $(LOCAL_NESTOR) ollama

LOCAL_NESTOR_OLLAMA_8B_MODELS ?= \
 qwen3:8b \
 llama3.1:8b

OLLAMA_MODELS ?= \
	$(LOCAL_NESTOR_OLLAMA_8B_MODELS:%:8b=local-nestor-pull-ollama-8b-%-model)

$(LOCAL_NESTOR_OLLAMA_8B_MODELS:%:8b=local-nestor-pull-ollama-8b-%-model):
	@echo "Pulling model $(@:local-nestor-pull-ollama-8b-%-model=%) with ollama..."
	@echo "Pulling model $(@:local-nestor-pull-ollama-8b-%-model=%) with ollama..."
	$(LOCAL_NESTOR_OLLAMA) pull $(@:local-nestor-pull-ollama-8b-%-model=%):8b
.PHONY: $(LOCAL_NESTOR_OLLAMA_8B_MODELS:%:8b=local-nestor-pull-ollama-8b-%-model)

local-nestor-pull-models: $(OLLAMA_MODELS)
	@echo "All models pulled successfully."
.PHONY: local-nestor-pull-models


local-nestor-ollama-server: local-nestor-ollama-server-up local-nestor-ollama-pull-models
	@echo "Ollama server is running and models are pulled."
.PHONY: local-nestor-ollama-server

local-nestor-ollama-server-up: local-nestor-ollama
	@echo "Starting ollama server..."
	$(LOCAL_NESTOR_OLLAMA) serve
.PHONY: local-nestor-ollama-server-up
