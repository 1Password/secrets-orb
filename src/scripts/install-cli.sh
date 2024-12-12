# shellcheck disable=SC2148
# Colors
NO_COLOR="\033[0m"
OK_COLOR="\033[32;01m"
ERROR_COLOR="\033[31;01m"

OP_CLI_VERSION=${PARAM_CLI_VERSION}
if ! [[ ${OP_CLI_VERSION} == v* ]]; then
    OP_CLI_VERSION="v${PARAM_CLI_VERSION}"
fi

# Make sure we have root priviliges.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if ! [ "$(command -v sudo)" ]; then
        echo -e "${ERROR_COLOR}Installer requires root privileges. Please run this script as root.${NO_COLOR}"
        exit 1;
    fi
    SUDO="sudo"
fi

# Install op-cli
if [[ "$OSTYPE" == "linux"* ]]; then
    ARCH=$(uname -m)
    if [ "$(getconf LONG_BIT)" = 32 ]; then
        ARCH="386"
    elif [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" == "aarch64" ]; then
        ARCH="arm64"
    fi

    echo "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_CLI_VERSION}/op_linux_${ARCH}_${OP_CLI_VERSION}.zip"
    curl -sSfLo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_CLI_VERSION}/op_linux_${ARCH}_${OP_CLI_VERSION}.zip"
    $SUDO unzip -od "$PARAM_PATH" op.zip && rm op.zip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    curl -sSfLo op.pkg "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_CLI_VERSION}/op_apple_universal_${OP_CLI_VERSION}.pkg"
    $SUDO installer -pkg op.pkg -target "$PARAM_PATH" && rm op.pkg
else 
    echo -e "${ERROR_COLOR}Cannot determine OS type. Exiting...${NO_COLOR}"
    exit 1;
fi
echo -e "${OK_COLOR}==> 1Password CLI successfully installed. ${NO_COLOR}"
