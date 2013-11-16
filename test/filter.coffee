assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_s    = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_.filter', ->
  it 'accepts fn (sync/async), calls it on each chunk, then passes the chunk along if fn returns true', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> chunk.a?
    asynch = (chunk, cb) -> cb null, chunk.a? # TODO: error handling
    expected = input.slice 0, 1
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _s(_s.fromArray input).chain().filter(spy).toArray (err, result) ->
        assert.ifError err
        assert.deepEqual expected, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        cb_fe()
    , done
