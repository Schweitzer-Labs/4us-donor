SHELL			:= bash
export CREPES		:= $(PWD)/cfn/bin/crepes.py
export SUBDOMAIN	:= donate
export PRODUCT		:= 4us

ifeq ($(RUNENV), )
       export RUNENV	:= qa
endif

# Deduce the Domain related parameters based on the RUNENV and PRODUCT params
ifeq ($(RUNENV), qa)
        export REGION   := us-west-2
	export DOMAIN   := build4
	export TLD      := us
else ifeq ($(RUNENV), prod)
        export REGION   := us-east-1
	export DOMAIN   := 4us
	export TLD      := net
else ifeq ($(RUNENV), demo)
        export REGION   := us-west-1
	export DOMAIN   := 4usdemo
	export TLD      := com
	export SUBDOMAIN	:= donate-api
endif

export STACK		:= $(RUNENV)-$(PRODUCT)-$(SUBDOMAIN)

export DATE		:= $(shell date)

export ENDPOINT		:= https://cloudformation-fips.$(REGION).amazonaws.com

export BUILD_DIR	:= $(PWD)/.build
export ELM_BUILD_DIR	:= $(PWD)/build

export TEMPLATE		:= $(BUILD_DIR)/template.yml
export PACKAGE		:= $(BUILD_DIR)/CloudFormation-template.yml


CFN_SRC_DIR		:= $(PWD)/cfn/template
SRCS			:= $(shell find $(CFN_SRC_DIR)/0* -name '*.yml' -o -name '*.txt')

export CFN_BUCKET	:= $(PRODUCT)-cfn-templates-$(REGION)
export WEB_BUCKET	:= $(SUBDOMAIN)-$(RUNENV).$(DOMAIN).$(TLD)-$(REGION)

export CREPES_PARAMS	:= --region $(REGION)
export CREPES_PARAMS	+= --subdomain $(SUBDOMAIN) --domain $(DOMAIN) --tld $(TLD) --runenv $(RUNENV) --product $(PRODUCT)

COMMITTEE_DIR		:= $(PWD)/committees
COMMITTEE_SRCS		:= $(shell find $(COMMITTEE_SRCS) -mindepth 1 -maxdepth 1 -type d)

ifeq ($(COMMITTEE), )
	COMMITTEE	:= john-safford
endif
COMMITTEE_DIR		:= committees/$(COMMITTEE)

.PHONY: all dep build build-cfn build-web check import package deploy deploy-web clean realclean

# Make targets
all: build

dep:
	@pip3 install -r requirements.txt

install-build-tools:
	@npm install create-elm-app

clean:
	@rm -f $(BUILD_DIR)/*.yml

realclean: clean
	@rm -rf $(BUILD_DIR)
	@rm -rf $(ELM_BUILD_DIR)

build: build-stacks build-web

build-stacks: $(BUILD_DIR)
	@$(MAKE) -C $(CFN_SRC_DIR) build

$(BUILD_DIR):
	@mkdir -p $@

build-committees: $(COMMITTEE_SRCS)

build-web: $(BUILD_DIR)
	@npm install
	#npm run build-css
	@npm \
		--runenv=$(RUNENV) \
		--subdomain=$(SUBDOMAIN) --domain=$(DOMAIN) --tld=$(TLD) \
		run build

check: build
	@$(MAKE) -C $(CFN_SRC_DIR) $@

package: build
	@$(MAKE) -C $(CFN_SRC_DIR) $@

deploy-infra: package
	@$(MAKE) -C $(CFN_SRC_DIR) deploy

deploy-web: build-web
	aws s3 sync build/ s3://$(WEB_BUCKET)/

deploy: deploy-infra deploy-web

buildimports: $(BUILD_DIR)
	@$(MAKE) -C $(CFN_SRC_DIR) $@

import: $(BUILD_DIR) buildimports
	@$(MAKE) -C $(CFN_SRC_DIR) $@

replication:
	@$(MAKE) -C cfn/replication deploy
