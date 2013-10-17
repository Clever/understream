_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_.mixin require("#{__dirname}/../index").exports()

describe 'paging with limit and skip', ->
  it 'allows us to get a middle page', (done) ->
    inp = [0..100]
    LIMIT = 10
    SKIP = 10
    _(inp).stream().skip(SKIP).limit(LIMIT).run (err, results) ->
      assert.ifError err
      expected = [SKIP...SKIP+LIMIT]
      assert.deepEqual results, expected
      done()
