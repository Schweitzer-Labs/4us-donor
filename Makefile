SHELL			:= bash
export SUBDOMAIN	:= donate
export PRODUCT		:= 4us
REPO_NAME		:= 4us-donor

# Deduce the Domain related parameters based on the RUNENV and PRODUCT params
ifeq ($(RUNENV), prod)
	export DOMAIN   := 4us
	export TLD      := net
else ifeq ($(RUNENV), demo)
	export DOMAIN   := 4usdemo
	export TLD      := com
else
	export RUNENV	:= qa
	export DOMAIN   := build4
	export TLD      := us
endif

export BUILD_DIR	:= $(PWD)/build

API_ENDPOINT	:= https://$(SUBDOMAIN)-api.$(DOMAIN).$(TLD)/api/platform/contribute

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
	bash send_slack.sh $(REPO_NAME) succeeded

cloudflare-begin:
	bash send_slack.sh $(REPO_NAME) started

cloudflare-failed:
	bash send_slack.sh $(REPO_NAME) failed
