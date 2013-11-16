assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_s = require "#{__dirname}/../index"

describe '_.invoke', ->
  it 'works', (done) ->
    input = [{m: () -> '1'}, {m: () -> '2'}]
    _s(_s.fromArray input).chain().invoke('m').toArray (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).invoke('m')
      done()
