.data[] | select(.capabilities.type == "chat" and (.policy.state == "enabled" or .policy == null)) |
"  - model_name: " + .id + "
    litellm_params:
      model: github_copilot/" + .id + "
      extra_headers: {\"Editor-Version\": \"vscode/1.108.2\", \"Copilot-Integration-Id\": \"vscode-chat\"}
    # " + .name + " (" + .vendor + ") - " + (.policy.state // "enabled") + "
    # Max tokens: " + (.capabilities.limits.max_output_tokens | tostring) + ", Context: " + (.capabilities.limits.max_context_window_tokens | tostring) + "
"
