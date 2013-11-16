_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"

describe '_.rest', ->
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
