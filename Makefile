TOKEN_FILE = ~/.config/litellm/github_copilot/access-token
MODELS_API = https://api.business.githubcopilot.com/models
PORT = 4445

install:
	uv tool install litellm
	uv tool upgrade litellm

run: install
	@echo "Local LiteLLM Api Key:" $$(grep "master_key" litellm-config.yaml | cut -d: -f 2)
	uv run litellm --config litellm-config.yaml --port $(PORT)

model_config.yaml: get_model_config.jq
	@echo 'model_list:' > model_config.yaml
	@curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $$(cat $(TOKEN_FILE))" \
		-H 'Editor-Version: vscode/1.107.0' \
		'$(MODELS_API)' | jq -r -f get_model_config.jq >> model_config.yaml

.PHONY: install run model_config.yaml
