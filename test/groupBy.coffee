assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
Understream = require "#{__dirname}/../index"

describe '_.groupBy', ->
  it 'fn', (done) ->
    new Understream([1.3, 2.1, 2.4]).groupBy(Math.floor).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{1: [1.3], 2: [2.1, 2.4]}]
      done()

  it 'string', (done) ->
    new Understream(['one', 'two', 'three']).groupBy('length').run (err, data) ->
      assert.ifError err
      assert.deepEqual [{3: ["one", "two"], 5: ["three"]}], data
      done()

  it 'can unpack into > 1 object', (done) ->
    new Understream([1.3, 2.1, 2.4]).groupBy({ fn: Math.floor, unpack: true }).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()

  it 'supports an async function, not unpacked', (done) ->
    new Understream([1.3, 2.1, 2.4]).groupBy({ fn: ((num, cb) -> cb null, Math.floor num) }).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {1: [1.3], 2: [2.1,2.4]} ]
      done()

  it 'supports an async function, unpacked', (done) ->
    new Understream([1.3, 2.1, 2.4]).groupBy({ fn: ((num, cb) -> cb null, Math.floor num), unpack: true }).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()
