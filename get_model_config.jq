.data[]
| select(.capabilities.type == "chat" and (.policy.state == "enabled" or .policy == null))
| (.supported_endpoints // []) as $endpoints
| (if ($endpoints | any(startswith("/responses"))) and ($endpoints | index("/chat/completions") | not)
   then "\n    model_info:\n      mode: responses"
   else ""
   end) as $model_info
|
"  - model_name: copilot-" + .id + "
    litellm_params:
      model: github_copilot/" + .id + $model_info + "
    # " + .name + " (" + .vendor + ") - " + (.policy.state // "enabled") + "
    # Max tokens: " + (.capabilities.limits.max_output_tokens | tostring) + ", Context: " + (.capabilities.limits.max_context_window_tokens | tostring) + "
"
