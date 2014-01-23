_     = require 'underscore'
assert = require 'assert'
async = require 'async'
Understream = require "#{__dirname}/../index"

describe 'paging with limit and skip', ->
  it 'allows us to get a middle page', (done) ->
    inp = [0..100]
    LIMIT = 10
    SKIP = 10
    new Understream(inp).rest(SKIP).first(LIMIT).run (err, results) ->
      assert.ifError err
      expected = [SKIP...SKIP+LIMIT]
      assert.deepEqual results, expected
      done()
