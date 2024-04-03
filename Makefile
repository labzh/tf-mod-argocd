# Make will use bash instead of sh
SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
TERRAFORM_VERSION := 0.12.31
TERRAFORM_DOCS_VERSION := 0.14.1

.PHONY: generate_docs
generate_docs:
	docker run --rm -t \
		-v $(CURDIR):/workspace \
		"quay.io/terraform-docs/terraform-docs":${TERRAFORM_DOCS_VERSION} \
		markdown /workspace

.PHONY: fmt
fmt:
	docker run --rm -t \
		-v $(CURDIR):/workspace \
		"hashicorp/terraform":${TERRAFORM_VERSION} \
		fmt -recursive /workspace