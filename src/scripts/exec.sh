#!/bin/bash

# User-Agent info for 1Password CLI
export OP_INTEGRATION_NAME="1Password CircleCI Secrets Orb"
export OP_INTEGRATION_ID="CIR"
export OP_INTEGRATION_BUILDNUMBER="1000001"

if [ -n "${PARAM_FLAGS}" ]; then
    op run "${PARAM_FLAGS}" -- "$SHELL" -c "${PARAM_COMMAND}"
else
    op run -- "$SHELL" -c "${PARAM_COMMAND}"
fi
