assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon = require 'sinon'

describe '_.queue', ->
  it 'accepts fn, calls it on each chunk, then passes the original chunk along', (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    spy = sinon.spy (chunk, cb) -> setTimeout (-> cb null, chunk), 10
    _(input).stream().queue(spy).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      assert.equal spy.callCount, 2
      assert.deepEqual spy.args[i][0], input[i] for i in input.length
      done()

  it "doesn't release the zalgo", (done) ->
    input = (i for i in [0...1000])
    recur = (i, result, cb) ->
      return cb null, result unless i
      recur i - 1, result, cb
    spy = sinon.spy (chunk, cb) -> recur 20, chunk, cb
    _(input).stream().queue(spy).run (err) ->
      assert.ifError err
      assert.equal spy.callCount, 1000
      done()

  _([1, 2, 3]).each (concurrency) ->
    it "stream properly obeys backpressure with concurrency #{concurrency}", (done) ->
      input  = [{a:'1'}, {b:'2'}, {c:'3'}, {d:'4'}, {e:'5'}, {f:'6'}, {g:'7'}]
      fn = (chunk, cb) -> setTimeout (-> cb null, chunk), 10
      num_read = num_received = 0
      queue_stream = _(input).stream().queue({fn, concurrency})
      old_transform = queue_stream.stream()._transform
      queue_stream.stream()._transform = ->
        num_read += 1
        old_transform.apply @, _(arguments).toArray()
      queue_stream
        .each (result) ->
          num_received += 1
          assert num_read - num_received <= concurrency
        .run done

  it 'successfully handles an error in the queue', (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    fn = (chunk, cb) -> setTimeout (-> cb 'some error', chunk), 10
    _(input).stream().queue(fn).run (err) ->
      assert.equal err, 'some error'
      done()

  it "doesn't end the stream if you return undefined", (done) ->
    input  = [{a:'1', b:'2'}, {c:'2', d:'3'}]
    spy = sinon.spy (chunk, cb) -> setTimeout cb, 10
    _(input).stream().queue(fn: spy, concurrency: 1).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, []
      assert.equal spy.callCount, 2
      assert.deepEqual spy.args[i][0], input[i] for i in input.length
      done()

  it 'supports arrays as items', (done) ->
    input = [[1, 2], ['a', 'b', 'c'], []]
    fn = (chunk, cb) -> setImmediate -> cb null, chunk
    _(input).stream().queue({fn}).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, input
      done()
