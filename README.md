# Reusable P2P

This is a reusable Github Actions P2P for CECG's Developer Platform

## Fast Feedback - Usage

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

  increment-version:
    uses: coreeng/p2p/.github/workflows/increment-version.yaml@v0.15.0
    secrets:
      git-token: ${{ secrets.GITHUB_TOKEN }}
    with:
      dry-run: ${{ github.ref != 'refs/heads/main' }}

  p2p:
    uses: coreeng/p2p/.github/workflows/p2p.yaml@promote
    needs: increment-version
    secrets:
      env_vars: |
        DOMAIN=${{ vars.DOMAIN }}
        ENVIRONMENT=${{ vars.DEV_ENV }}
        TAG_VERSION=${{ needs.increment-version.outputs.version }}
    with:
      dev-env-name: ${{ vars.DEV_ENV }}
      dev-project-id: ${{ vars.DEV_PROJECT_ID }}
      dev-project-number: ${{ vars.DEV_PROJECT_NUMBER }}
      tenant-name: ${{ vars.TENANT_NAME }}

```

This will also generate a new semantic version with a `v` prefix that you can use to tag your application.


## Extended Tests - Usage
```
name: Extended Tests
on:
  schedule:
    - cron: '0 22 * * 1-5'

permissions:
  contents: read
  id-token: write

jobs:

  p2p:
    uses: coreeng/p2p/.github/workflows/extended-tests.yaml@0.2.0
    secrets:
      env_vars: |
        DOMAIN=${{ vars.DOMAIN }}
        DEV_ENVIRONMENT=${{ vars.DEV_ENV }}
        PROD_ENVIRONMENT=${{ vars.PRD_ENV }}
    with:
      dev-env-name: ${{ vars.DEV_ENV }}
      prod-env-name: ${{ vars.PROD_ENV }}
      dev-project-id: ${{ vars.DEV_PROJECT_ID }}
      prod-project-id: ${{ vars.PROD_PROJECT_ID }}
      dev-project-number: ${{ vars.DEV_PROJECT_NUMBER }}
      prod-project-number: ${{ vars.PROD_PROJECT_NUMBER }}
      tenant-name: ${{ vars.TENANT_NAME }}

```

This run on a cron and will should promote the latest image that successfully passed the fast feedback phase. If this is successful, it will promote the image to be deployed in production.

## Production - Usage
```
name: Production

on:
  workflow_dispatch: # This forces the job to only be triggered manually

permissions:
  contents: read
  id-token: write

jobs:

  p2p:
    uses: coreeng/p2p/.github/workflows/prod.yaml@0.0.2
    secrets:
      env_vars: |
        DOMAIN=${{ vars.DOMAIN }}
        ENVIRONMENT=${{ vars.PROD_ENV }}
        TAG_VERSION=${{ needs.increment-version.outputs.version }}
    with:
      prod-env-name: ${{ vars.PROD_ENV }}
      prod-project-id: ${{ vars.PROD_PROJECT_ID }}
      prod-project-number: ${{ vars.PROD_PROJECT_NUMBER }}
      tenant-name: ${{ vars.TENANT_NAME }}
```

This job will execute the production deployment. In this example it is configured to be manually triggered only.

## General usages
For all jobs the `env_vars` secret will be use to propagate env vars to your Makefile calls. They will be redacted from the output so you can pass sensitive information like credentials as they're coming in as `secrets`.

## Makefile
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
p2p-prepare-promotion-extended-tests: ## Optional task to repare promotion to extended tests
	echo "##### EXECUTING P2P-PREPARE-PROMOTION-EXTENDED-TESTS #####"

.PHONY: p2p-promote-prod
p2p-promote-prod: ## Promote to prod phase
	echo "##### EXECUTING P2P-PROMOTE-PROD #####"

.PHONY: p2p-prepare-promotion-prod
p2p-prepare-promotion-prod: ## Optional task to repare promotion to production
	echo "##### EXECUTING P2P-PREPARE-PROMOTION-PROD #####"

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
