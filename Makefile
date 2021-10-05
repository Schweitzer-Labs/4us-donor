SHELL			:= bash
export SUBDOMAIN	:= donate
export PRODUCT		:= 4us

ifeq ($(RUNENV), )
       export RUNENV	:= qa
endif

# Deduce the Domain related parameters based on the RUNENV and PRODUCT params
ifeq ($(RUNENV), qa)
	export DOMAIN   := build4
	export TLD      := us
else ifeq ($(RUNENV), prod)
	export DOMAIN   := 4us
	export TLD      := net
else ifeq ($(RUNENV), demo)
	export DOMAIN   := 4usdemo
	export TLD      := com
endif

export BUILD_DIR	:= $(PWD)/build

API_ENDPOINT	:= https://$(SUBDOMAIN)-api.$(DOMAIN).$(TLD)/api/platform/contribute

export CF_PAGES_BRANCH	:= $(CF_PAGES_BRANCH)
export SLACK_HOOK	:= $(SLACK_HOOK)
SLACK_URL       := https://hooks.slack.com/services/$(SLACK_HOOK)

.PHONY: all dep build clean

# Make targets
all: build

dep:
	@npm install create-elm-app
	@npm install

clean:
	@rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $@

build: $(BUILD_DIR) dep
	#npm run build-css
	@npm \
		--runenv=$(RUNENV) \
		--subdomain=$(SUBDOMAIN) --domain=$(DOMAIN) --tld=$(TLD) \
		--apiendpoint=$(API_ENDPOINT) \
		run build

cloudflare-web: build
	curl \
                -X POST \
                -H 'Content-type: application/json' \
                --data '{"text":"Build succeeded: $(CF_PAGES_BRANCH) branch of 4us-donor"}' $(SLACK_URL)

cloudflare-failed:
	curl \
                -X POST \
                -H 'Content-type: application/json' \
                --data '{"text":"Build failed: $(CF_PAGES_BRANCH) branch of 4us-donor"}' $(SLACK_URL)
