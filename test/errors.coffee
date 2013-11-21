assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

# domain_thrown (0,8) vs domainThrown (0.10)
was_thrown = (domain_err) ->
  return domain_err.domain_thrown if domain_err.domain_thrown?
  domain_err.domainThrown

describe '_.stream error handling', ->

  it 'run() requires an error handler', () ->
    assert.throws () ->
      _([]).stream().run()
    , Error

  it "allows user to handle any emitted errors", (done) ->
    async.forEachSeries ['each', 'filter', 'map'], (fn, cb_fe) ->
      cnt = 0
      bad_fn = (input, cb) ->
        if cnt++ is 0 then cb(null, input) else cb(new Error('one and done')) # emit
      _([1,2,3]).stream()[fn](bad_fn).run (err) ->
        assert.equal err.message, 'one and done'
        cb_fe()
    , done

  it "allows user to handle any thrown errors", (done) ->
    return done() if process.versions.node.match /^0\.8/
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt++ is 0 then cb(null, input) else throw new Error('one and done') # throw
    _([1,2,3]).stream().each(bad_fn).run (err) ->
      assert.equal was_thrown(err), true, "Expected error caught by domain to be thrown"
      assert.equal err.message, 'one and done'
      done()

  it "allows user to handle any asynchronously emitted errors", (done) ->
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt++ is 0
        cb null, input
      else
        setTimeout (()->cb(new Error('one and done'))), 500
    _([1,2,3]).stream().each(bad_fn).run (err) ->
      assert.equal err.message, 'one and done'
      done()

  it "allows user to handle any asynchronously thrown errors", (done) ->
    return done() if process.versions.node.match /^0\.8/
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt++ is 0
        cb null, input
      else
        setTimeout (() -> throw new Error('one and done')), 500
    _([1,2,3]).stream().each(bad_fn).run (err) ->
      assert.equal was_thrown(err), true, "Expected error caught by domain to be thrown"
      assert.equal err.message, 'one and done'
      done()

  expected_err = -> new Error('from another stream')
  _.each
    emitted: (i, cb) -> cb expected_err()
    thrown: (i, cb) -> throw expected_err()
    async_emitted: (i, cb) -> setImmediate -> cb expected_err()
    async_thrown: (i, cb) -> setImmediate -> throw expected_err()
  , (bad_fn, action) ->
    _.each ['readable', 'duplex'], (getter) ->
      it "catches #{action} errors from any stream in the entire pipeline using #{getter}", (done) ->
        other_pipeline = _.stream([1]).each(bad_fn).each(->)[getter]()
        _(other_pipeline).stream().each(->).run (err) ->
          assert err?, 'Expected error'
          assert.deepEqual err.message, expected_err().message
          done()
