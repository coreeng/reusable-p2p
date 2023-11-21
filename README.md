# Reusable P2P

This is a reusable Github Actions P2P for CECG's Developer Platform

## Usage

Create a workflow on your repository to use the p2p.yaml workflow

```
name: P2P
on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main

permissions:
  contents: read
  id-token: write

jobs:
  p2p:
    uses: coreeng/p2p/.github/workflows/p2p.yaml@v0.0.2
    secrets:
      env_vars: |
        TEST_VARIABLE=value
    with:
      dev-env-name: ${{ vars.DEV_ENV }}
      dev-project-id: ${{ vars.DEV_PROJECT_ID }}
      dev-project-number: ${{ vars.DEV_PROJECT_NUMBER }}
      tenant-name: ${{ vars.TENANT_NAME }}
```

The `env_vars` secret will be use to propagate env vars to your Makefile calls. They will be redacted from the output so you can pass sensitive information like credentials as they're coming in as `secrets`.
### Makefile
The P2P pipeline assumes you have the following tasks on your makefile:

```
.PHONY: p2p-build 
p2p-build: ## Build phase
	echo "##### EXECUTING P2P-BUILD #####"

.PHONY: p2p-functional 
p2p-functional: ## Execute functional tests
	echo "##### EXECUTING P2P-FUNCTIONAL #####"

.PHONY: p2p-nft
p2p-nft:  ## Execute functional tests
	echo "##### EXECUTING P2P-NFT #####"

.PHONY: p2p-promote-extended-tests
p2p-promote-extended-tests: ## Promote to extended-tests phase
	echo "##### EXECUTING P2P-PROMOTE-EXTENDED-TESTS #####"

.PHONY: p2p-prepare-promotion-extended-tests
p2p-prepare-promotion-extended-tests: ## Prepare promotion to extended tests
	echo "##### EXECUTING P2P-PREPARE-PROMOTION-EXTENDED-TESTS #####"

.PHONY: p2p-promote-prod
p2p-promote-prod: ## Promote to prod phase
	echo "##### EXECUTING P2P-PROMOTE-PROD #####"

.PHONY: p2p-extended-tests
p2p-extended-tests: ## Run Extended Tests
	echo "##### EXECUTING P2P-EXTENDED-TESTS #####"

.PHONY: p2p-prod
p2p-prod: ## Deploys to production
	echo "##### EXECUTING P2P-PROD #####"

```

These will be your entrypoint. Any custom action you'd like the pipeline to do should be defined as dependencies on these ones.

## Versioning
This pipeline uses semantic versioning. When creating your pipeline, check the latest version. (eg `uses: coreeng/p2p/.github/workflows/p2p.yaml@v0.0.2`)
