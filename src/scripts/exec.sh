#!/bin/bash
if [ -n "${PARAM_FLAGS}" ]; then
    op run "${PARAM_FLAGS}" -- "$SHELL" -c "${PARAM_COMMAND}"
else
    op run -- "$SHELL" -c "${PARAM_COMMAND}"
fi
