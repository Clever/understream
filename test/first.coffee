_     = require 'underscore'
assert = require 'assert'
async = require 'async'
Understream = require "#{__dirname}/../index"

describe '_.first', ->
  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  it 'sends through all objects if limit > size of stream', (done) ->
    input = [0..10]
    new Understream(input).first(100).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      done()

  it 'sends through limit objects if limit < size of stream', (done) ->
    LIMIT = 5
    input = [0..10]
    new Understream(input).first(LIMIT).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).first(LIMIT)
      done()

  # It's important to read every object from the source stream in case there
  # are other streams also reading from the source stream. If this stream stops
  # reading from the source stream, backpressure applied by this stream will
  # cause the stream to stop pulling new data, which will prevent other streams
  # from reading from it as well.
  it 'reads every object from the source stream, discarding objects after the limit', (done) ->
    LIMIT = 5
    input = [0..100]
    seen = 0
    new Understream(input)
      # Ensure there's no buffering, otherwise the objects could get past the
      # each() but be buffered before first() and the test would still past.
      # Without buffers, we guarantee that every object that goes through
      # each() goes through first().
      .defaults(objectMode: true, highWaterMark: 0)
      .each(-> seen++)
      .first(LIMIT)
      .run (err, result) ->
        assert.ifError err
        assert.equal seen, input.length
        assert.equal result.length, LIMIT
        done()
