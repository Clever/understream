assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.value', ->
  [
    [{a:'1', b:'2'}]
    []
  ].forEach (input, i) ->
    it "ends the stream chain and returns an array #{i}", (done) ->
      _(input).stream().value (result) ->
        assert.deepEqual input, result
        done()
      .run assert.ifError
