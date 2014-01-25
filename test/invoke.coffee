assert = require 'assert'
async = require 'async'
_     = require 'underscore'
Understream = require "#{__dirname}/../index"

describe '_.invoke', ->
  it 'works', (done) ->
    input = [{m: () -> '1'}, {m: () -> '2'}]
    new Understream(input).invoke('m').run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).invoke('m')
      done()
