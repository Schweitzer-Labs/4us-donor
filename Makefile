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

.PHONY: all dep build clean

# Make targets
all: build

dep:
	@npm install create-elm-app

clean:
	@rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $@

build: $(BUILD_DIR) dep
	@npm install
	#npm run build-css
	@npm \
		--runenv=$(RUNENV) \
		--subdomain=$(SUBDOMAIN) --domain=$(DOMAIN) --tld=$(TLD) \
		--apiendpoint=$(API_ENDPOINT) \
		run build
