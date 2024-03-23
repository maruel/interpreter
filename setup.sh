#!/bin/bash
# Copyright 2024 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

set -eu
cd "$(dirname $0)"

if [ ! -f venv/bin/activate ]; then
  echo "Setting up virtualenv"
  # Do not use "virtualenv" since it won't use the right python3 version.
  python3 -m venv venv
fi

./upgrade.sh

# https://docs.openinterpreter.com/language-models/local-models/llamafile
# This model fits a computer with 32GB of RAM.
# TODO: Buy more RAM.
MODEL=mixtral-8x7b-instruct-v0.1.Q3_K_M.llamafile

if [ ! -f $MODEL ]; then
  if [ ! -f huggingface.key ]; then
    echo "Get token at https://huggingface.co/settings/tokens and put it in huggingface.key"
    exit 1
  fi
  curl -L -O \
    -H "Authorization: Bearer $(cat huggingface.key)" \
    https://huggingface.co/jartine/Mixtral-8x7B-Instruct-v0.1-llamafile/resolve/main/$MODEL
  chmod +x $MODEL
fi
