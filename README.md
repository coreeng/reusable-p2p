# Reusable P2P

This is a reusable Github Actions P2P for CECG's IDP

## Usage

Create a workflow on your repository to use the idp-p2p.yaml workflow

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
    uses: coreeng/reusable-p2p/.github/workflows/p2p.yaml@v0.0.1
    with:
      project-id: ${{ vars.PROJECT_ID }}
      project-number: ${{ vars.PROJECT_NUMBER }}
      tenant-name: ${{ vars.TENANT_NAME }}

```
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

.PHONY: p2p-dev
p2p-dev:  ## Deploys to dev environment
	echo "##### EXECUTING P2P-DEV #####"
```

These will be your entrypoint. Any custom action you'd like the pipeline to do should be defined as dependencies on these ones.

## Versioning
This pipeline uses semantic versioning. When creating your pipeline, check the latest version. (eg `uses: coreeng/reusable-p2p/.github/workflows/idp-p2p.yaml@v0.0.2`)