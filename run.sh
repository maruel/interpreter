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
    --custom_instructions "Vous parlez français" &

  wait
}

claude() {
  # See https://github.com/OpenInterpreter/open-interpreter/issues/1056
  #  --model openrouter/anthropic/claude-3-opus
  # https://docs.litellm.ai/docs/providers/anthropic
  #  --verbose
  interpreter \
    --model claude-3-sonnet-20240229 \
    --api_key $(cat claude.key) \
    --context_window 200000 \
    --max_tokens 4000 \
    --custom_instructions "Vous parlez français"
}

claude
