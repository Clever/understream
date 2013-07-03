# usage:
# `make` or `make test` runs all the tests
# `make successful_run` runs just that test
.PHONY=test test-contrib test-cov

# errors.coffee broken
TESTS=$(shell cd test && ls *.coffee | grep -v errors | sed s/\.coffee$$//)
CONTRIB_TESTS=$(shell cd contrib/test && ls *.coffee | sed s/\.coffee$$//)

all: test

test: $(TESTS)

test-contrib: $(CONTRIB_TESTS)

$(TESTS):
	DEBUG=* NODE_ENV=test node_modules/mocha/bin/mocha --timeout 60000 --compilers coffee:coffee-script test/$@.coffee
$(CONTRIB_TESTS):
	DEBUG=* NODE_ENV=test node_modules/mocha/bin/mocha --timeout 60000 --compilers coffee:coffee-script contrib/test/$@.coffee

test-cov:
	# compile lib/ for coverage test
	rm -rf lib-js
	coffee -c -o lib-js lib
	# instrument the js code w/ jscoverage hooks
	rm -rf lib-js-cov
	jscoverage lib-js lib-js-cov
	NODE_ENV=test TEST_UNDERSTREAM_COV=1 node_modules/mocha/bin/mocha --compilers coffee:coffee-script -R html-cov test/{test,csv,sqlite}.coffee | tee coverage.html
	open coverage.html
