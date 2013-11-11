assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.where', ->
  it 'works', (done) ->
    input = [{a: 1, b: 2}, {a: 2, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}]
    _(input).stream().where({a: 1}).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).where({a: 1})
      done()
