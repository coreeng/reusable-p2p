projectDir := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
os := $(shell uname)

.PHONY: help
help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# P2P tasks

.PHONY: p2p-build
p2p-build: ## Build phase
	echo "##### EXECUTING P2P-BUILD #####"

.PHONY: p2p-functional
p2p-functional: ## Execute functional tests
	echo "##### EXECUTING P2P-FUNCTIONAL #####"

.PHONY: p2p-nft
p2p-nft:  ## Execute non-functional tests
	echo "##### EXECUTING P2P-NFT #####"

.PHONY: p2p-dev
p2p-dev:  ## Deploys to dev environment
	echo "##### EXECUTING P2P-DEV #####"

.PHONY: p2p-promote-extended-tests
p2p-promote-extended-tests: ## Promote to extended-tests phase
	echo "##### EXECUTING P2P-PROMOTE-EXTENDED-TESTS #####"

.PHONY: p2p-promote-prod
p2p-promote-prod: ## Promote to prod phase
	echo "##### EXECUTING P2P-PROMOTE_PROD #####"

.PHONY: test-var-print
test-var-print :## Test task
	echo $${TEST_VARIABLE}

.PHONY: test-pre-step
test-pre-step:## Test pre-step
	echo "##### EXECUTING TEST-PRE-TASK $${SOME_SECRET} #####"

.PHONY: test-post-step
test-post-step:## Test post-step
	echo "##### EXECUTING TEST-POST-TASK $${SOME_SECRET} #####"
