_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
test_helpers = require "#{__dirname}/helpers"

describe '_.rest', ->
  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  return if test_helpers.node_major() is 10 and test_helpers.node_minor() < 20

  it 'skips some objects if skip < size of stream', (done) ->
    SKIP = 5
    input = [0..10]
    _s(_s.fromArray input).chain().rest(SKIP).toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).rest(SKIP)
      done()

  it 'skips all objects if skip size > size of stream', (done) ->
    SKIP = 100
    input = [0..10]
    _s(_s.fromArray input).chain().rest(SKIP).toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, []
      done()
