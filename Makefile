# commands
EMACS ?= emacs
MAKEM = ./makem.sh/makem.sh

# directories
SANDBOX = ./sandbox

# makem options
MAKEM_LINT = lint-compile lint-declare lint-indent lint-package lint-regexps
MAKEM_TEST = tests
MAKEM_SANDBOX =

# tasks

.PHONY: default
default: test

.PHONY: init
init:
	git submodule update --init

.PHONY: clean
clean:
	-rm *.el
	-rm -r $(SANDBOX)

.PHONY: compile
compile:
	$(MAKEM) compile --emacs $(EMACS) --verbose

.PHONY: test
test:
# lint-checkdoc may report false positive errors and warnings.
# run lint-checkdoc as advice.
	-$(MAKEM) lint-checkdoc --emacs $(EMACS) --verbose $(MAKEM_SANDBOX)
	$(MAKEM) $(MAKEM_LINT) $(MAKEM_TEST) --emacs $(EMACS) --verbose $(MAKEM_SANDBOX) --install-deps --install-linters

.PHONY: test-sandboxed
test-sandboxed:
	$(MAKE) test MAKEM_SANDBOX="--sandbox=$(SANDBOX)"
