# usage:
# `make` or `make test` runs all the tests
# `make successful_run` runs just that test
.PHONY=test test-contrib test-cov

TESTS=$(shell cd test && ls *.coffee | sed s/\.coffee$$//)

all: test

test: $(TESTS)

$(TESTS):
	DEBUG=* NODE_ENV=test node_modules/mocha/bin/mocha --timeout 60000 --compilers coffee:coffee-script test/$@.coffee

test-cov:
	rm -rf lib-js
	node_modules/coffee-script/bin/coffee -c -o lib-js lib
	rm -rf lib-js-cov
	jscoverage lib-js lib-js-cov
	NODE_ENV=test TEST_UNDERSTREAM_COV=1 node_modules/mocha/bin/mocha --compilers coffee:coffee-script -R html-cov test/*.coffee | tee coverage.html
	open coverage.html

publish:
	$(eval VERSION := $(shell grep version package.json | sed -ne 's/^[ ]*"version":[ ]*"\([0-9\.]*\)",/\1/p';))
	@echo \'$(VERSION)\'
	$(eval REPLY := $(shell read -p "Publish and tag as $(VERSION)? " -n 1 -r; echo $$REPLY))
	@echo \'$(REPLY)\'
	@if [[ $(REPLY) =~ ^[Yy]$$ ]]; then \
	    npm publish; \
	    git tag -a v$(VERSION) -m "version $(VERSION)"; \
	    git push --tags; \
	fi
