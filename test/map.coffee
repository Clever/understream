assert = require 'assert'
async = require 'async'
_     = require 'underscore'
Understream = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_.map', ->
  synch  = (chunk) -> _(chunk).keys()
  asynch = (chunk, cb) -> cb null, _(chunk).keys() # TODO: error handling

  _.each [synch, asynch], (fn) ->

    it "accepts fn #{fn}, calls it on each chunk, then passes the fn result along", (done) ->
      input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
      expected = _(input).map(_.keys)
      spy = sinon.spy fn
      new Understream(input).map(spy).run (err, result) ->
        assert.ifError err
        assert.deepEqual expected, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        done()

    it "does not block fn #{fn} setTimeout while running", (done) ->
      input = ({a:i, b:i+1} for i in [1..100])  # spend some time in the stream
      expected = _(input).map(_.keys)
      spy = sinon.spy fn

      timeout_ran = false
      setTimeout ->  # setup a timeout that will run soon
        timeout_ran = true
      , 10
      new Understream(input).map(spy).run (err, result) ->
        assert.equal timeout_ran, true  # make sure setTimeout ran during map
        assert.ifError err
        assert.deepEqual expected, result
        assert.equal spy.callCount, 100
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        done()
