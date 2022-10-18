# shellcheck disable=SC2148
random_heredoc_identifier=$(env LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 64 | head -n 1) || true
{
    printf "export %s=$(cat \<<" ""${PARAM_VAR_NAME}""
    printf "%s'\n'" ""${random_heredoc_identifier}""
    op read ""${PARAM_SECRET_REFERENCE}""
    printf "%s'\n')\n" "${random_heredoc_identifier}"
} >> "$BASH_ENV"