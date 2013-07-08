assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.groupBy', ->
  it 'fn', (done) ->
    _([1.3, 2.1, 2.4]).stream().groupBy(Math.floor).value (data) ->
      assert.deepEqual data, [{1: [1.3], 2: [2.1, 2.4]}]
      done()
    .run assert.ifError

  it 'string', (done) ->
    _(['one', 'two', 'three']).stream().groupBy('length').value (data) ->
      assert.deepEqual [{3: ["one", "two"], 5: ["three"]}], data
      done()
    .run assert.ifError

  it 'can unpack into > 1 object', (done) ->
    _([1.3, 2.1, 2.4]).stream().groupBy({ fn: Math.floor, unpack: true }).value (data) ->
      assert.deepEqual data, [ {'1':[1.3]}, {'2':[2.1,2.4]} ]
      done()
    .run assert.ifError
