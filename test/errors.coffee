assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
Understream = require "#{__dirname}/../index"
{Readable} = require 'stream'
{DEFAULT_MAX_LISTENERS} = require '../lib/helpers'

# domain_thrown (0,8) vs domainThrown (0.10)
was_thrown = (domain_err) ->
  return domain_err.domain_thrown if domain_err.domain_thrown?
  domain_err.domainThrown

describe '_.stream error handling', ->

  it 'run() requires an error handler', ->
    assert.throws ->
      new Understream([]).run()
    , Error

  it "allows user to handle any emitted errors", (done) ->
    async.forEachSeries ['each', 'filter', 'map'], (fn, cb_fe) ->
      cnt = 0
      bad_fn = (input, cb) ->
        if cnt is 0
          cb null, input
        else
          cb new Error 'one and done'
        cnt += 1
      new Understream([1,2,3])[fn](bad_fn).run (err) ->
        assert.equal err.message, 'one and done'
        cb_fe()
    , done

  it "allows user to handle any thrown errors", (done) ->
    return done() if process.versions.node.match /^0\.8/
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt is 0
        cb null, input
      else
        throw new Error 'one and done'
      cnt += 1
    new Understream([1,2,3]).each(bad_fn).run (err) ->
      assert.equal was_thrown(err), true, "Expected error caught by domain to be thrown"
      assert.equal err.message, 'one and done'
      done()

  it "allows user to handle any asynchronously emitted errors", (done) ->
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt is 0
        cb null, input
      else
        setTimeout (-> cb new Error 'one and done'), 500
      cnt += 1
    new Understream([1,2,3]).each(bad_fn).run (err) ->
      assert.equal err.message, 'one and done'
      done()

  it "allows user to handle any asynchronously thrown errors", (done) ->
    return done() if process.versions.node.match /^0\.8/
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt is 0
        cb null, input
      else
        setTimeout (-> throw new Error 'one and done'), 500
      cnt += 1
    new Understream([1,2,3]).each(bad_fn).run (err) ->
      assert.equal was_thrown(err), true, "Expected error caught by domain to be thrown"
      assert.equal err.message, 'one and done'
      done()

  expected_err = -> new Error('from another stream')
  _.each
    emitted: (i, cb) -> cb expected_err()
    thrown: (i, cb) -> throw expected_err()
    async_emitted: (i, cb) -> setImmediate -> cb expected_err()
    async_thrown: (i, cb) -> setImmediate -> throw expected_err()
    async_nested_thrown: (i, cb) -> setImmediate -> setImmediate -> setImmediate -> throw expected_err()
  , (bad_fn, action) ->
    _.each ['readable', 'duplex'], (getter) ->
      it "catches #{action} errors from any stream in the entire pipeline using #{getter}", (done) ->
        other_pipeline = new Understream([1]).each(bad_fn).each(-> )[getter]()
        new Understream(other_pipeline).each(-> ).run (err) ->
          assert err?, 'Expected error'
          assert.deepEqual err.message, expected_err().message
          done()

    it "catches #{action} errors from the join 'from' stream", (done) ->
      new Understream(['to']).join
        from: new Understream(['from']).each(bad_fn).each(-> ).readable()
        on: 'doesnt matter'
        type: 'inner'
      .run (err) ->
        assert err?, 'Expected error'
        assert.deepEqual err.message, expected_err().message
        done()

    it "catches #{action} errors from streams passed to combine", (done) ->
      combine = new Understream().combine([
        new Understream([1]).readable()
        new Understream([2]).each(bad_fn).each(->).readable()
      ]).run (err) ->
        assert err?, 'Expected error'
        assert.deepEqual err.message, expected_err().message
        done()

  # For backwards-compatibility with streams created by old versions of Understream, in which the
  # _pipeline method returned the stream itself among other streams.
  it "doesnt infinitely loop on streams whose _pipeline method returns the stream itself", (done) ->
    stream = new Understream([1]).each(->).readable()
    pipeline = stream._pipeline()
    stream._pipeline = -> pipeline.concat [stream]
    new Understream(stream).run done

  describe 'maxListeners', ->
    describe 'increases the limit to account for error handlers it adds', ->
      num_listeners = (stream) -> stream.listeners('error').length + stream.listeners('end').length

      stream = new Understream([]).stream()
      _.each ['once', 'again'], (time) -> it time, (done) ->
        starting_max_listeners = stream._maxListeners || DEFAULT_MAX_LISTENERS
        starting_listeners = num_listeners stream
        new Understream(stream).each(-> ).run (err) ->
          assert.ifError err
          added_listeners = num_listeners(stream) - starting_listeners
          increase_in_max_listeners = stream._maxListeners - starting_max_listeners
          assert.equal increase_in_max_listeners, added_listeners,
            "Expected maxListeners to increase by the number of added handlers, #{added_listeners}," +
            " but found that it increased by #{increase_in_max_listeners}" +
            " (from #{starting_max_listeners} to #{stream._maxListeners})"
          done()
    it 'does not crash if there are no maxListeners', (done) ->
      stream = new Understream([]).stream()
      delete stream._maxListeners
      new_stream = new Understream(stream).each(-> ).run (err) ->
        assert.ifError err
        done()
        
        

  class ErrorStream extends Readable
    contructor: (_) ->

    _read: ->
     @emit 'error', new Error("Error")
     return @push null

  it 'should only get one callback if stream errors then ends', (done) ->
    new Understream(new ErrorStream()).run (err) ->
      assert err
      # If done is called multiple times then mocha will complain
      done()
