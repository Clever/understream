var path = __dirname + '/' + (process.env.TEST_UNDERSTREAM_COV ? 'lib-js-cov' : 'lib-js') + '/understream';
module.exports = require(path);
