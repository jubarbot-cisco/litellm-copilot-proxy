# LiteLLM proxy Configuration

<https://docs.litellm.ai/docs/tutorials/github_copilot_integration>

## Installation

`make install`

## Configuration

Update the `master_key` in the `config.yaml` file. This is the key you will use
to query your own, local, LiteLLM instance.

## Start

Then start it.

`make run`

The first time, it will ask you to authenticate to your GitHub
Copilot Cisco account. (likely `CEC_cisco`, mine is `jubarbot_cisco`).

```
16:40:49 - LiteLLM:WARNING: authenticator.py:149 - Error reading API endpoint from file: [Errno 2] No such file or directory: '/Users/jubarbot/.config/litellm/github_copilot/api-key.json'
16:40:49 - LiteLLM:WARNING: authenticator.py:105 - No API key file found or error opening file
16:40:49 - LiteLLM:WARNING: authenticator.py:60 - No existing access token found or error reading file
Please visit https://github.com/login/device and enter code B63E-1BB3 to authenticate.
```

## Test

```
curl --location 'http://0.0.0.0:4445/chat/completions' \
--header 'Authorization: Bearer litellm-my-private-local-key' \
--header 'Content-Type: application/json' \
--data '{
      "model": "gemini-3-pro-preview",
      "messages": [
        {
          "role": "user",
          "content": "Write a C program that segfaults faster than light"
        }
      ]
    }
'
```

## Update models

In case new models are provided for you GitHub Copilot account, you can later update
the `models_config.yaml` with `make models_config.yaml`.

## Integrations

### Claude Code CLI

In `~/.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-my-private-local-key",
    "ANTHROPIC_BASE_URL": "http://localhost:4445",
    "ANTHROPIC_MODEL": "claude-sonnet-4.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4.5",
  },
  "model": "opus"
}
```

### Gemini CLI

Not working for me:

```
export GOOGLE_GEMINI_BASE_URL="http://localhost:4445"
export GEMINI_API_KEY=litellm-my-private-local-key
```
