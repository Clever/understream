assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon = require 'sinon'
Readable = require 'readable-stream'

describe '_.stream', ->

  error_free = (err) -> assert.ifError err

  it '.stream() ends the stream chain and returns the last stream in the chain', ->
    assert _([]).stream().stream() instanceof Readable

  it '.value() ends the stream chain and returns an array', (done) ->
    input = [{a:'1', b:'2'}]
    _(input).stream().value((result) ->
      assert.deepEqual input, result
      done()
    ).run error_free

  it '.value() ends the stream chain and returns an array 2', (done) ->
    input = []
    _(input).stream().value (result) ->
      assert.deepEqual input, result
      done()
    .run error_free

  it 'wraps a Readable stream instance', (done) ->
    input = ['a', 'b', 'c']
    rs = new Readable objectMode: true
    rs.push item for item in input
    rs.push null
    _(rs).stream().value((result) ->
      assert.deepEqual input, result
      done()
    ).run error_free

  it '.each() accepts fn (sync/async), calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> null
    asynch = (chunk, cb) -> cb null, chunk # TODO: error handling
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _(input).stream().each(spy).value (result) ->
        assert.deepEqual input, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy,args[i][0], input[i] for i in input.length
        cb_fe()
      .run error_free
    , done

  it '.map() accepts fn (sync/async), calls it on each chunk, then passes the fn result along', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> _(chunk).keys()
    asynch = (chunk, cb) -> cb null, _(chunk).keys() # TODO: error handling
    expected = _(input).map(_.keys)
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _(input).stream().map(spy).value (result) ->
        assert.deepEqual expected, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy,args[i][0], input[i] for i in input.length
        cb_fe()
      .run error_free
    , done

  it '.filter() accepts fn (sync/async), calls it on each chunk, then passes the chunk along if fn returns true', (done) ->
    input  = [{a:'1', b:'2'},{c:'2', d:'3'}]
    synch  = (chunk) -> chunk.a?
    asynch = (chunk, cb) -> cb null, chunk.a? # TODO: error handling
    expected = input.slice 0, 1
    async.forEach [synch, asynch], (fn, cb_fe) ->
      spy = sinon.spy fn
      _(input).stream().filter(spy).value (result) ->
        assert.deepEqual expected, result
        assert.equal spy.callCount, 2
        assert.deepEqual spy,args[i][0], input[i] for i in input.length
        cb_fe()
      .run error_free
    , done
