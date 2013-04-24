.PHONY=test test-cov
test-cov:
	# compile lib/ for coverage test
	rm -rf lib-js
	coffee -c -o lib-js lib
	# instrument the js code w/ jscoverage hooks
	rm -rf lib-js-cov
	jscoverage lib-js lib-js-cov
	NODE_ENV=test TEST_UNDERSTREAM_COV=1 node_modules/mocha/bin/mocha --compilers coffee:coffee-script -R html-cov test/{test,csv,sqlite}.coffee | tee coverage.html
	open coverage.html

test:
	# not working: errors
	DEBUG=* NODE_ENV=test node_modules/mocha/bin/mocha --compilers coffee:coffee-script test/{test,csv,sqlite,join,mixin}.coffee
