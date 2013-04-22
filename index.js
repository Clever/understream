require('coffee-script');
var path = __dirname + '/' + (process.env.TEST_UNDERSTREAM_COV ? 'lib-js-cov' : 'lib') + '/understream';
module.exports = require(path);
