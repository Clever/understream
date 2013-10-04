assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.groupBy', ->
  it 'fn', (done) ->
    _([1.3, 2.1, 2.4]).stream().groupBy(Math.floor).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{1: [1.3], 2: [2.1, 2.4]}]
      done()

  it 'string', (done) ->
    _(['one', 'two', 'three']).stream().groupBy('length').run (err, data) ->
      assert.ifError err
      assert.deepEqual [{3: ["one", "two"], 5: ["three"]}], data
      done()

  it 'can unpack into > 1 object', (done) ->
    _([1.3, 2.1, 2.4]).stream().groupBy({ fn: Math.floor, unpack: true }).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()
