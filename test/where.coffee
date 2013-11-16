assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_s    = require "#{__dirname}/../index"

describe '_.where', ->
  it 'works', (done) ->
    input = [{a: 1, b: 2}, {a: 2, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}]
    _s(_s.fromArray input).chain().where({a: 1}).toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).where({a: 1})
      done()
