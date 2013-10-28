assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.flatten', ->
  it 'flattens one level when shallow', (done) ->
    input = [[3], [[4]]]
    _(input).stream().flatten(true).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).flatten(true)
      done()

  it 'flattens all levels when not shallow', (done) ->
    input = [[3], [[4]]]
    _(input).stream().flatten().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).flatten()
      done()
