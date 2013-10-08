assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon = require 'sinon'

describe '_.each', ->
  it 'accepts fn (sync/async), calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> null
    asynch = (chunk, cb) -> cb null, chunk # TODO: error handling
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _(input).stream().each(spy).run (err, result) ->
        assert.ifError err
        assert.deepEqual input, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy.args[i][0], input[i] for i in input.length
        cb_fe()
    , done
