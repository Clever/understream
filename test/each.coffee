assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_.each', ->
  it 'accepts fn (sync/async), calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> null
    asynch = (chunk, cb) -> cb null, chunk
    async.forEach [synch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _s(input).chain().fromArray(input).each(spy).toArray (err, result) ->
        assert.ifError err
        assert.deepEqual input, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        cb_fe()
    , done
