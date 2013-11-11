_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_.mixin require("#{__dirname}/../index").exports()

describe '_.first', ->
  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  it 'sends through all objects if limit > size of stream', (done) ->
    input = [0..10]
    _(input).stream().first(100).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      done()

  it 'sends through limit objects if limit < size of stream', (done) ->
    LIMIT = 5
    input = [0..10]
    _(input).stream().first(LIMIT).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).first(LIMIT)
      done()

  it 'only sees limit + highWaterMark objects', (done) ->
    LIMIT = 5
    HIGHWATERMARK = 1
    input = [0..100]
    seen = 0
    _(input).stream().defaults(objectMode: true, highWaterMark: HIGHWATERMARK).each(-> seen++).first(LIMIT).run (err, result) ->
      assert.ifError err
      assert.equal seen, LIMIT+HIGHWATERMARK*2 # 1 highWaterMark for buffering in first, 1 highWaterMark for buffering in each
      done()
