assert = require 'assert'
async = require 'async'
_     = require 'underscore'
Understream = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_.map', ->
  it 'accepts fn (sync/async), calls it on each chunk, then passes the fn result along', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> _(chunk).keys()
    asynch = (chunk, cb) -> cb null, _(chunk).keys() # TODO: error handling
    expected = _(input).map(_.keys)
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      new Understream(input).map(spy).run (err, result) ->
        assert.ifError err
        assert.deepEqual expected, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        cb_fe()
    , done

  it 'fn (sync/async), do not block setTimeout while running', (done) ->
    input = []
    for i in [1..100]  # spend some time in the stream
      d = {}
      d["a#{i}"] = i.toString()
      d["b#{i}"] = i+1
      input.push d
    synch  = (chunk) -> _(chunk).keys()
    asynch = (chunk, cb) -> cb null, _(chunk).keys() # TODO: error handling
    expected = _(input).map(_.keys)
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      nextTick = false
      setTimeout =>  # setup a timeout that will run soon
        nextTick = true
      , 10
      new Understream(input).map(spy).run (err, result) ->
        assert.equal nextTick, true  # make sure setTimeout ran during map
        assert.ifError err
        assert.deepEqual expected, result
        assert.equal spy.callCount, 100
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        cb_fe()
    , done
