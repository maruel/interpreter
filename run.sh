#!/bin/bash
# Copyright 2024 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

set -eu
cd "$(dirname $0)"
if [ ! -f venv/bin/activate ]; then
  echo "Run ./setup.sh first"
  exit 1
fi
source venv/bin/activate

trap terminate SIGINT
terminate() {
  pkill -SIGINT -P $$
  exit
}

# https://docs.openinterpreter.com/guides/running-locally
# --api_key
# ollama run dolphin-mixtral:8x7b-v2.6

# https://docs.openinterpreter.com/guides/os-mode
# --os
#  --model ollama/dolphin-mixtral:8x7b-v2.63 \

mixtral() {
  # Run the local model.
  ./mixtral-8x7b-instruct-v0.1.Q3_K_M.llamafile &
  interpreter \
      --model mixtral-8x7b-instruct \
      --context_window 32768 \
      --api_base http://localhost:8080/v1 \
      --custom_instructions "Vous parlez français" \
      "$@" &
  wait
}

gpt() {
  echo "Monitor 💰 at https://platform.openai.com/usage"
  #
  # https://openai.com/pricing
  # GPT-4 Turbo:              10$/MTok /  30$/MTok / 128k
  # GPT-4:                    30$/MTok /  60$/MTok / 8k
  # GPT-4 32k:                60$/MTok / 120$/MTok / 32k
  # GPT-3.5 Turbo instruct: 1.50$/MTok /   2$/MTok / 4k (not good enough)
  #
  # See model names at https://docs.litellm.ai/docs/providers/openai
  #
  # https://help.openai.com/en/articles/8555510-gpt-4-turbo-in-the-openai-api
  MODEL=gpt-4-turbo-preview
  #MODEL=gpt-4-1106-preview
  #MODEL=gpt-4
  export OPENAI_API_KEY="$(cat gpt.key)"
  interpreter --model $MODEL --api_key $OPENAI_API_KEY \
      --context_window 128000 \
      --max_tokens 4096 \
      --custom_instructions "Vous parlez français" \
      "$@"
}

claude() {
  echo "Monitor 💰 at https://console.anthropic.com/settings/usage"
  #
  # https://www.anthropic.com/api
  # - Haiku:  0.25$/MTok / 1.25$/MTok / 200k
  # - Sonnet:    3$/MTok /   15$/MTok / 200k
  # - Opus:     15$/MTok /   75$/MTok / 200k
  # - 2.1:       8$/MTok /   24$/MTok / 200k
  #
  # See https://github.com/OpenInterpreter/open-interpreter/issues/1056
  #  --model openrouter/anthropic/claude-3-opus
  #
  # See model names at https://docs.litellm.ai/docs/providers/anthropic
  interpreter \
      --model claude-3-sonnet-20240229 \
      --api_key $(cat claude.key) \
      --context_window 200000 \
      --max_tokens 4000 \
      --custom_instructions "Vous parlez français" \
      "$@"
}

gemini() {
  # https://ai.google.dev/
  echo "Not tested, not available in Canada."
}

#claude
#gemini
gpt
