# 1Password Secrets Orb for CircleCI

[![CircleCI Build Status](https://circleci.com/gh/1Password/secrets-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/1Password/secrets-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/onepassword/secrets.svg)](https://circleci.com/orbs/registry/orb/onepassword/secrets) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/1Password/secrets-orb/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

With the 1Password Secrets orb for CircleCI, you can load secrets from 1Password into CircleCI CI/CD pipelines and sync them automatically. Using this orb removes the risk of exposing plaintext secrets in code.

You can use the orb with [1Password Connect Server](https://developer.1password.com/docs/connect) or a [1Password Service Account](https://developer.1password.com/docs/service-accounts)<sup>BETA</sup>.

This orb is officially supported and maintained by 1Password, but community contributions are welcome.

Read more on the [1Password Developer Portal](https://developer.1password.com/ci-cd/circle-ci).

## Requirements

Before you get started, if you want to use Connect, you'll need to:

- [Set up a Secrets Automation workflow](https://developer.1password.com/docs/connect/get-started#step-1-set-up-a-secrets-automation-workflow).
- [Deploy 1Password Connect](https://developer.1password.com/docs/connect/get-started#step-2-deploy-1password-connect-server) in your infrastructure.
- On the [CircleCI settings page](https://circleci.com/docs/settings/), set the `OP_CONNECT_HOST` and `OP_CONNECT_TOKEN` environment variables to your Connect instance's credentials so that it'll be used to load secrets.

If you want to use Service Accounts<sup>BETA</sup>, you'll need to:

- [Create a service account.](https://developer.1password.com//docs/service-accounts/)
- On the [CircleCI settings page](https://circleci.com/docs/settings/), set the `OP_SERVICE_ACCOUNT_TOKEN` environment variable to your service account's credentials so that it'll be used to load secrets.

**NOTE:** If either `OP_CONNECT_HOST` or `OP_CONNECT_TOKEN` environment variables have been set alongside `OP_SERVICE_ACCOUNT_TOKEN`, the Connect credentials will take precedence over the provided service account token. You must unset the Connect environment variables to ensure the action uses the service account token.

## Usage examples

### Install 1Password CLI within a Circle CI job

1Password CLI needs to be available to the pipeline for the orb to function. You can install the CLI as the first step of a CircleCI job using the `1password/install-cli` command. Once installed, you can use 1Password CLI commands in subsequent steps in the pipeline.

```yaml
version: 2.1
orbs:
  1password: onepassword/secrets@1.0.0

jobs:
  deploy:
    machine:
      image: ubuntu-2204:current
    steps:
      - 1password/install-cli
      - checkout
      - run:
          shell: op run -- /bin/bash
          environment:
            AWS_ACCESS_KEY_ID: op://company/app/aws/access_key_id
            AWS_SECRET_ACCESS_KEY: op://company/app/aws/secret_access_key
          command: |
            echo "This value will be masked: $AWS_ACCESS_KEY_ID"
            echo "This value will be masked: $AWS_SECRET_ACCESS_KEY"
            ./deploy-my-app.sh

workflows:
  deploy:
    jobs:
      - deploy
```

If you want to use the orb with a [1Password Service Account](/docs/service-accounts/)<sup>BETA</sup>, specify a beta version of the command-line tool (`2.16.0-beta.01` or later).

```yaml
version: 2.1
orbs:
  1password: onepassword/secrets@1.0.0

jobs:
  deploy:
    machine:
      image: ubuntu-2204:current
    steps:
      - 1password/install-cli:
          version: 2.16.0-beta.01
      - checkout
      - run:
          shell: op run -- /bin/bash
          environment:
            AWS_ACCESS_KEY_ID: op://company/app/aws/access_key_id
            AWS_SECRET_ACCESS_KEY: op://company/app/aws/secret_access_key
          command: |
            echo "This value will be masked: $AWS_ACCESS_KEY_ID"
            echo "This value will be masked: $AWS_SECRET_ACCESS_KEY"
            ./deploy-my-app.sh

workflows:
  deploy:
    jobs:
      - deploy
```

<details>
    <summary>Another example, with Docker</summary>

```yaml
description: >
  Install 1Password CLI within a job and make it useable for all the commands following the installation.
usage:
  version: 2.1
  orbs:
    1password: onepassword/secrets@1.0.0
  jobs:
    deploy:
      machine:
        image: ubuntu-2204:current
      steps:
        - 1password/install-cli
        - checkout
        - run: |
            docker login -u $(op read op://company/docker/username) -p $(op read op://company/docker/password)
            docker build -t company/app:${CIRCLE_SHA1:0:7} .
            docker push company/app:${CIRCLE_SHA1:0:7}
  workflows:
    deploy:
      jobs:
        - deploy
```

</details>

### Load secrets with the `1password/exec` command

First, install 1Password CLI with `1password/install-cli`. Then use the `1password/exec` command to load secrets on demand and execute commands requiring secrets. Sensitive values that may be accidentally logged will be masked. After adding the `1password/exec` command as a step in your job, you can execute commands that require secrets.

```yaml
version: 2.1
orbs:
  1password: onepassword/secrets@1.0.0

jobs:
  deploy:
    machine:
      image: ubuntu-2204:current
    environment:
      AWS_ACCESS_KEY_ID: op://company/app/aws/access_key_id
      AWS_SECRET_ACCESS_KEY: op://company/app/aws/secret_access_key
    steps:
      - checkout
      - 1password/install-cli
      - 1password/exec:
          command: |
            echo "This value will be masked: $AWS_ACCESS_KEY_ID"
            echo "This value will be masked: $AWS_SECRET_ACCESS_KEY"
            ./deploy-my-app.sh
workflows:
  deploy:
    jobs:
      - deploy
```

### Load secrets with the `1password/export` command

You can use `1password/export` to resolve variables at the job level.

First, install 1Password CLI with `1password/install-cli`. Then use the `1password/export` command to load the secrets with references exported in the environment. The secrets will then be available to subsequent steps of the job.

_Note: Unlike `1password/exec`, the export command does not mask the secret values from the logs._

```yaml
version: 2.1
orbs:
  1password: onepassword/secrets@1.0.0

jobs:
  deploy:
    machine:
      image: ubuntu-2204:current
    steps:
      - checkout
      - 1password/install-cli
      - 1password/export:
          var-name: AWS_ACCESS_KEY_ID
          secret-reference: op://company/app/aws/access_key_id
      - 1password/export:
          var-name: AWS_SECRET_ACCESS_KEY
          secret-reference: op://company/app/aws/secret_access_key
      - run:
          command: |
            echo "This value will not be masked: $AWS_ACCESS_KEY_ID"
            echo "This value will not be masked: $AWS_SECRET_ACCESS_KEY"
            ./deploy-my-app.sh
workflows:
  deploy:
    jobs:
      - deploy
```

## Including the orb in your project

To include a specific version of the orb, add the following in your `config.yml` file (replace `1.0.0` with the desired version number):

```yaml
orbs:
  1password: onepassword/secrets@1.0.0
```

To include the _latest_ version of 1Password Secrets orb in your project, add the following:

```yaml
orbs:
  1password: onepassword/secrets@volatile
```

## Masking

When using either the `1password/exec` orb command or the [`op run`](https://developer.1password.com/docs/cli/reference/commands/run) shell wrapper, all secrets are automatically masked from the CI log output. If secrets accidentally get logged, they will be replaced with `<concealed by 1Password>`.

If you use the `1password/export` command, secrets aren't masked.

## Resources

- [1Password Secrets orb CircleCI registry page <i className="fas fa-external-link"></i>](https://circleci.com/orbs/registry/orb/onepassword/secrets). This official registry page contains information on all versions and commands.
- Learn more about using [CircleCI orbs. <i className="fas fa-external-link"></i>](https://circleci.com/docs/orb-intro/)

## How to Contribute

We welcome creating [issues](https://github.com/1Password/secrets-orb/issues) in and [pull requests](https://github.com/1Password/secrets-orb/pulls) against the `secrets-orb` repository!

## Security

1Password requests you practice responsible disclosure if you discover a vulnerability.

Please file requests through [BugCrowd](https://bugcrowd.com/agilebits).

For information about our security practices, visit the [1Password Security homepage](https://1password.com/security).

## Getting help

If you find yourself stuck, visit our [**Support Page**](https://developer.1password.com/ci-cd) for help.
