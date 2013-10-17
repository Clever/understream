_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_.mixin require("#{__dirname}/../index").exports()

describe '_.rest', ->
  it 'skips some objects if skip < size of stream', (done) ->
    SKIP = 5
    input = [0..10]
    _(input).stream().rest(SKIP).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).last(input.length - SKIP)
      done()

  it 'skips all objects if skip size > size of stream', (done) ->
    SKIP = 100
    input = [0..10]
    _(input).stream().rest(SKIP).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, []
      done()
