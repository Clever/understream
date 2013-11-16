assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_s     = require "#{__dirname}/../index"

describe '_.groupBy', ->
  it 'fn', (done) ->
    _s(_s.fromArray [1.3, 2.1, 2.4]).chain().groupBy(Math.floor).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{1: [1.3], 2: [2.1, 2.4]}]
      done()

  it 'string', (done) ->
    _s(_s.fromArray ['one', 'two', 'three']).chain().groupBy('length').toArray (err, data) ->
      assert.ifError err
      assert.deepEqual [{3: ["one", "two"], 5: ["three"]}], data
      done()

  it 'can unpack into > 1 object', (done) ->
    _s(_s.fromArray [1.3, 2.1, 2.4]).chain().groupBy({ fn: Math.floor, unpack: true }).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()

  it 'supports an async function, not unpacked', (done) ->
    _s(_s.fromArray [1.3, 2.1, 2.4]).chain().groupBy({ fn: ((num, cb) -> cb null, Math.floor num) }).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {1: [1.3], 2: [2.1,2.4]} ]
      done()

  it 'supports an async function, unpacked', (done) ->
    _s(_s.fromArray [1.3, 2.1, 2.4]).chain().groupBy({ fn: ((num, cb) -> cb null, Math.floor num), unpack: true }).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()
