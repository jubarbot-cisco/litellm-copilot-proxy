API_KEY_FILE = ~/.config/litellm/github_copilot/api-key.json
ACCESS_TOKEN_FILE = ~/.config/litellm/github_copilot/access-token
MODELS_API = https://api.business.githubcopilot.com/models
PORT = 4445
PYTHON_VERSION = 3.12

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
	uv tool install --python $(PYTHON_VERSION) 'litellm[proxy]'
	uv tool upgrade --python $(PYTHON_VERSION) 'litellm[proxy]'

run: install
	@echo "Local LiteLLM Api Key:" $$(grep "master_key" litellm-config.yaml | cut -d: -f 2)
	uv tool run --python $(PYTHON_VERSION) litellm --config litellm-config.yaml --port $(PORT)

model_config.yaml:
	@echo 'model_list:' > model_config.yaml

	@curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $(call get_token)" \
		-H 'Editor-Version: vscode/1.108.2' \
		'$(MODELS_API)' | jq -r -f get_model_config.jq >> model_config.yaml

.PHONY: install run model_config.yaml
