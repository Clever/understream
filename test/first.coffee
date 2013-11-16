_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"

describe '_.first', ->
  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  it 'sends through all objects if limit > size of stream', (done) ->
    input = [0..10]
    _s(_s.fromArray input).chain().first(100).toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      done()

  it 'sends through limit objects if limit < size of stream', (done) ->
    LIMIT = 5
    input = [0..10]
    _s(_s.fromArray input).chain().first(LIMIT).toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).first(LIMIT)
      done()

  it 'only sees limit + highWaterMark objects', (done) ->
    LIMIT = 5
    HIGHWATERMARK = 1
    input = [0..100]
    seen = 0
    _s(_s.fromArray input).chain()
    .each((-> seen++), {objectMode: true, highWaterMark: HIGHWATERMARK})
    .first(LIMIT, {objectMode: true, highWaterMark: HIGHWATERMARK})
    .toArray (err, result) ->
      assert.ifError err
      assert.equal seen, LIMIT+HIGHWATERMARK*2 # 1 highWaterMark for buffering in first, 1 highWaterMark for buffering in each
      done()
