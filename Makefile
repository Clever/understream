# usage:
# `make build` or `make` compiles lib/*.coffee to lib/*.js (for all changed lib/*.coffee)
# `make lib/transform/each.coffee` compiles just that file to lib-js
# `make test` runs all the tests
# `make test/each.coffee` runs just that test
.PHONY: test test-cov
TESTS=$(shell ls test/*.coffee | sed s/\.coffee$$//)
LIBS=$(shell find . -regex "^./lib\/.*\.coffee\$$" | sed s/\.coffee$$/\.js/ | sed s/lib/lib-js/)
MONGO_URL ?= mongodb://127.0.0.1:27017 # needed for tests

build: $(LIBS)

lib-js/%.js : lib/%.coffee
	node_modules/coffee-script/bin/coffee --bare -c -o $(@D) $(patsubst lib-js/%,lib/%,$(patsubst %.js,%.coffee,$@))

test: $(TESTS)

$(TESTS): build
	MONGO_URL=$(MONGO_URL) DEBUG=* NODE_ENV=test node_modules/mocha/bin/mocha --timeout 60000 --bail --compilers coffee:coffee-script $@.coffee

test-cov: build
	# jscoverage only accepts directory arguments so have to rebuild everything
	rm -rf lib-js-cov
	jscoverage lib-js lib-js-cov
	NODE_ENV=test TEST_UNDERSTREAM_COV=1 node_modules/mocha/bin/mocha --compilers coffee:coffee-script -R html-cov test/*.coffee | tee coverage.html
	open coverage.html

publish: clean build
	$(eval VERSION := $(shell grep version package.json | sed -ne 's/^[ ]*"version":[ ]*"\([0-9\.]*\)",/\1/p';))
	@echo \'$(VERSION)\'
	$(eval REPLY := $(shell read -p "Publish and tag as $(VERSION)? " -n 1 -r; echo $$REPLY))
	@echo \'$(REPLY)\'
	@if [[ $(REPLY) =~ ^[Yy]$$ ]]; then \
	    npm publish; \
	    git tag -a v$(VERSION) -m "version $(VERSION)"; \
	    git push --tags; \
	fi

clean:
	rm -rf lib-js lib-js-cov
