assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

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
        util = require 'util'
        assert.equal err.domain_thrown, false, "Expected error caught by domain to be emitted"
        assert.equal err.message, 'one and done'
        cb_fe()
    , done

  # it "allows user to handle any thrown errors", (done) ->
  #   cnt = 0
  #   bad_fn = (input, cb) ->
  #     if cnt++ is 0 then cb(null, input) else throw new Error('one and done') # throw
  #   _([1,2,3]).stream().each(bad_fn).run (err) ->
  #     assert.equal err.domain_thrown, true, "Expected error caught by domain to be thrown"
  #     assert.equal err.message, 'one and done'
  #     done()

  it "allows user to handle any asynchronously emitted errors", (done) ->
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt++ is 0
        cb null, input
      else
        setTimeout (()->cb(new Error('one and done'))), 500
    _([1,2,3]).stream().each(bad_fn).run (err) ->
      assert.equal err.domain_thrown, false, "Expected error caught by domain to be emitted"
      assert.equal err.message, 'one and done'
      done()

  # it "allows user to handle any asynchronously thrown errors", (done) ->
  #   cnt = 0
  #   bad_fn = (input, cb) ->
  #     if cnt++ is 0
  #       cb null, input
  #     else
  #       setTimeout (() -> throw new Error('one and done')), 500
  #   _([1,2,3]).stream().each(bad_fn).run (err) ->
  #     assert.equal err.domain_thrown, true, "Expected error caught by domain to be thrown"
  #     assert.equal err.message, 'one and done'
  #     done()
