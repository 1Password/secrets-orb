# 1Password Secrets Orb for CircleCI

[![CircleCI Build Status](https://circleci.com/gh/1Password/secrets-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/1Password/secrets-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/onepassword/secrets-orb.svg)](https://circleci.com/orbs/registry/orb/onepassword/secrets-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/1Password/secrets-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

The 1Password Secrets CircleCI Orb allows loading secrets from 1Password into CircleCI CI/CD pipelines, and syncing them automatically, therefore, removing the risk of exposing sensitive values.
This orb is officially supported and maintained by 1Password, but community contributions are welcome.

## Usage

You can make secrets available to the CircleCI jobs/steps by including references to them in the environment. References are of the form `op://vault/item/[section]/field`.

In order to install the 1Password CLI within a CircleCI job, the `1password/install-cli` command is available:
```yml
version: 2.1
orbs:
  1password: onepassword/secrets@x.y.z

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

<details>
  <summary> Alternative using `1password/exec` command</summary>

```yml 
version: 2.1
orbs:
  1password: onepassword/secrets@x.y.z

jobs:
  deploy:
    machine:
        image: ubuntu-2204:current
    environment:
      AWS_ACCESS_KEY_ID: op://company/app/aws/access_key_id
      AWS_SECRET_ACCESS_KEY: op://company/app/aws/secret_access_key
    steps:
      - checkout
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

</details>

In order to resolve variables at a job level, `1password/export` can be used:

```yml 
version: 2.1
orbs:
  1password: onepassword/secrets@x.y.z

jobs:
  deploy:
    machine:
        image: ubuntu-2204:current
    steps:
      - checkout
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

More examples are available in the `src/examples` directory.

## Including the orb in your project

In order to include a specific version of the orb:
```yaml
orbs:
  1password: onepassword/secrets@0.1.0
```

In order to include the latest version of 1Password Secrets CircleCI Orb in your project, add the following in your `config.yml`:
```yaml
orbs:
  1password: onepassword/secrets@volatile
```

## Authentication

The 1Password CircleCI orb relies on using 1Password Secrets Automation by running a 1Password Connect Server as well as a 1Password Connect token. For instructions on how to set up Secrets Automation and deploy Connect, please refer to the [official documentation](https://developer.1password.com/docs/connect).

Once you have a 1Password Connect host and token, configure `OP_CONNECT_HOST` and `OP_CONNECT_TOKEN` environment variables respectively.

## Masking

When using either the `1password/exec` orb command or the `op run` shell wrapper, all secrets are automatically masked from the CI log output. If secrets (accidentally) get logged, they will be replaced with:
`<concealed by 1Password>`

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/onepassword/secrets) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.
### How to Contribute

We welcome [issues](https://github.com/1Password/secrets-orb/issues) to and [pull requests](https://github.com/1Password/secrets-orb/pulls) against this repository!

### How to Publish An Update
1. Merge pull requests with desired changes to the main branch.
    - For the best experience, squash-and-merge and use [Conventional Commit Messages](https://conventionalcommits.org/).
2. Find the current version of the orb.
    - You can run `circleci orb info onepassword/secrets | grep "Latest"` to see the current version.
3. Create a [new Release](https://github.com/1Password/secrets-orb/releases/new) on GitHub.
    - Click "Choose a tag" and _create_ a new [semantically versioned](http://semver.org/) tag. (ex: v1.0.0)
      - We will have an opportunity to change this before we publish if needed after the next step.
4.  Click _"+ Auto-generate release notes"_.
    - This will create a summary of all of the merged pull requests since the previous release.
    - If you have used _[Conventional Commit Messages](https://conventionalcommits.org/)_ it will be easy to determine what types of changes were made, allowing you to ensure the correct version tag is being published.
5. Now ensure the version tag selected is semantically accurate based on the changes included.
6. Click _"Publish Release"_.
    - This will push a new tag and trigger your publishing pipeline on CircleCI.

## Security

1Password requests you practice responsible disclosure if you discover a vulnerability.

Please file requests via [**BugCrowd**](https://bugcrowd.com/agilebits).

For information about security practices, please visit our [Security homepage](https://bugcrowd.com/agilebits).

## Getting help

If you find yourself stuck, visit our [**Support Page**](https://support.1password.com/) for help.
