assert = require 'assert'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.transform', ->
  it 'works with a custom _transform function', (done) ->
    input = ['a', 'b', 'c']
    _(input).stream().transform (chunk, enc, cb) ->
      @push chunk
      @push chunk + '2'
      cb()
    .value (data) ->
      assert.deepEqual data, ['a', 'a2', 'b', 'b2', 'c', 'c2']
      done()
    .run assert.ifError

  it 'works with a custom _flush function', (done) ->
    input = ['a', 'b', 'c']
    _(input).stream().transform(
      (chunk, enc, cb) -> @push chunk; cb()
    , (cb) -> @push 'bye bye'; cb()
    ).value (data) ->
      assert.deepEqual data, input.concat ['bye bye']
      done()
    .run assert.ifError


