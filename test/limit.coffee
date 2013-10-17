_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_.mixin require("#{__dirname}/../index").exports()

describe '_.limit', ->
  it 'sends through all objects if limit > size of stream', (done) ->
    input = [0..10]
    _(input).stream().limit(100).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      done()

  it 'sends through limit objects if limit < size of stream', (done) ->
    LIMIT = 5
    input = [0..10]
    _(input).stream().limit(LIMIT).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).first(LIMIT)
      done()
