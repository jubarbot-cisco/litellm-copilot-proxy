LITELLM_VERSION = 1.89.1

API_KEY_FILE = ~/.config/litellm/github_copilot/api-key.json
ACCESS_TOKEN_FILE = ~/.config/litellm/github_copilot/access-token
MODELS_API = https://api.business.githubcopilot.com/models
PORT = 4445
PYTHON_VERSION = 3.14
NETWORK_NAME = local-tools

# Helper to get the token - checks expiration and chooses appropriate source
define get_token
$(shell \
	EXPIRES_AT=$$(jq -r '.expires_at' $(API_KEY_FILE) 2>/dev/null); \
	NOW=$$(date +%s); \
	if [ -n "$$EXPIRES_AT" ] && [ "$$EXPIRES_AT" -gt "$$NOW" ]; then \
		jq -r '.token' $(API_KEY_FILE); \
	else \
		cat $(ACCESS_TOKEN_FILE); \
	fi \
)
endef

install:
	echo "Nothing to do"
	uv tool install --python $(PYTHON_VERSION) 'litellm[proxy]==$(LITELLM_VERSION)'

run: install
	@echo "Local LiteLLM Api Key:" $$(grep "master_key" litellm-config.yaml | cut -d: -f 2)
	uv tool run --python $(PYTHON_VERSION) litellm --config litellm-config.yaml --port $(PORT)

model_config.yaml:
	@echo 'model_list:' > model_config.yaml

	@curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $(call get_token)" \
		-H 'Editor-Version: vscode/1.108.2' \
		'$(MODELS_API)' | jq -r -f get_model_config.jq >> model_config.yaml


docker-network:
	@docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || docker network create $(NETWORK_NAME)

docker-run: docker-network
	cosign verify --key https://raw.githubusercontent.com/BerriAI/litellm/0112e53046018d726492c814b3644b7d376029d0/cosign.pub ghcr.io/berriai/litellm:v$(LITELLM_VERSION)
	@echo "Local LiteLLM Api Key:" $$(grep "master_key" litellm-config.yaml | cut -d: -f 2)
	docker run --rm -it \
		--env-file .env \
		--name 'litellm-proxy' \
		--network $(NETWORK_NAME) \
		-p $(PORT):$(PORT) \
		-v $(PWD)/litellm-config.yaml:/app/litellm-config.yaml:ro \
		-v $(PWD)/model_config.yaml:/app/model_config.yaml:ro \
		-v $(PWD)/cisco_models_config.yaml:/app/cisco_models_config.yaml:ro \
		-v $(HOME)/.config/litellm/github_copilot:/root/.config/litellm/github_copilot \
		ghcr.io/berriai/litellm:v$(LITELLM_VERSION) \
		--config /app/litellm-config.yaml --host 0.0.0.0 --port $(PORT)

.PHONY: install run model_config.yaml docker-network docker-run
