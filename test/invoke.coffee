assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.invoke', ->
  it 'works', (done) ->
    input = [{m: () -> '1'}, {m: () -> '2'}]
    _(input).stream().invoke('m').run (err, result) ->
      assert.ifError err
      assert.deepEqual result, _(input).invoke('m')
      done()
