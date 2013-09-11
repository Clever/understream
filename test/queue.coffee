assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon = require 'sinon'

describe '_.queue', ->
  it 'accepts fn, calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    fn = (chunk, cb) -> setTimeout (-> cb null, chunk), 1000
    spy = sinon.spy fn
    _(input).stream().queue(spy).value (result) ->
      assert.deepEqual result, input
      assert.equal spy.callCount, 2
      assert.deepEqual spy.args[i][0], input[i] for i in input.length
      done()
    .run assert.ifError

  it 'with low concurency accepts fn, calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    fn = (chunk, cb) -> setTimeout (-> cb null, chunk), 1000
    spy = sinon.spy fn
    _(input).stream().queue(fn: spy, concurrency: 1).value (result) ->
      assert.deepEqual result, input
      assert.equal spy.callCount, 2
      assert.deepEqual spy.args[i][0], input[i] for i in input.length
      done()
    .run assert.ifError

  it 'successfully handles an erorr in the queue', (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    fn = (chunk, cb) -> setTimeout (-> cb 'some error', chunk), 1000
    _(input).stream().queue(fn).run (err) ->
      assert.equal err, 'some error'
      done()
