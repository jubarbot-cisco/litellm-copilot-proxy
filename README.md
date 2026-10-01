# Local LiteLLM gateway

One local endpoint for GitHub Copilot, Cisco Outshift, and Things models:

```text
OpenCode / Claude Code / other clients
                 |
         http://127.0.0.1:4445
                 |
              LiteLLM
       /          |          \
  Copilot       Cisco       Things
```

Model aliases are provider-qualified: `copilot-*`, `cisco-*`, and `things-*`.

## Setup

Install the native proxy:

```sh
make install
```

Create `.env` from `.env.example` and fill in the credentials available to
you:

```dotenv
LITELLM_MASTER_KEY=
CISCO_LLM_API_KEY=
THINGS_PAT=
```

`LITELLM_MASTER_KEY` authenticates local clients. The other keys authenticate
the corresponding upstream providers. Things also requires access to Cisco
DNS/VPN.

## Run

Run natively:

```sh
make run
```

Or run the verified LiteLLM image in Docker:

```sh
make docker-run
```

Both commands expose only `127.0.0.1:4445`. The first Copilot request may ask
you to authenticate through GitHub's device flow. Copilot credentials are kept
under `~/.config/litellm/github_copilot`.

## Check

Validate local configuration without calling an upstream provider:

```sh
make check
```

Check the running proxy:

```sh
curl -fsS http://127.0.0.1:4445/health/readiness

curl -fsS \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  http://127.0.0.1:4445/v1/models
```

Send a completion:

```sh
curl -fsS http://127.0.0.1:4445/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H 'Content-Type: application/json' \
  --data '{
    "model": "cisco-claude-haiku-4-5",
    "messages": [{"role": "user", "content": "Say hello in five words."}]
  }'
```

## Update Copilot models

Regenerate the Copilot model catalog after GitHub adds or removes models:

```sh
make model_config.yaml
make check
```

The generator marks Responses-only Copilot models with `mode: responses`, so
LiteLLM bridges `/chat/completions` clients to the correct upstream endpoint.

## OpenCode

The global `~/.config/opencode/opencode.json` uses the same endpoint and reads
its key from `{env:LITELLM_MASTER_KEY}`. Export that variable before starting
OpenCode.

## Claude Code

Example `~/.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$LITELLM_MASTER_KEY",
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:4445",
    "ANTHROPIC_MODEL": "cisco-claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "cisco-claude-haiku-4-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "cisco-claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "cisco-claude-opus-5"
  },
  "model": "opus"
}
```

Claude Code does not expand `$LITELLM_MASTER_KEY` inside JSON. Replace that
value or inject it through your shell/configuration manager.

## Optional routing

`litellm-config.yaml` contains inactive examples for:

- A complexity router using valid local model aliases.
- Same-provider failure fallbacks.

They remain commented because automatic fallback can send prompts to another
deployment, and the complexity router adds policy and classification behavior
that is not required for the single-endpoint gateway.
