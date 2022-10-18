# shellcheck disable=SC2148
if [ -z "${PARAM_FLAGS}" ]; then
    op run "${PARAM_FLAGS}" -- "$SHELL" -c "${PARAM_COMMAND}"
else
    op run -- "$SHELL" -c "${PARAM_COMMAND}"
fi
