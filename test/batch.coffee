assert = require 'assert'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

charRange = (start, stop) ->
  if not stop? then stop = start; start = 0
  _(_.range(start, stop))
    .map (i) -> 'abcdefghijklmnopqrstuvwxyz'[i]

describe '_.batch(n)', ->
  it 'waits for n items, then outputs them in an array', (done) ->
    _(charRange 20).stream().batch(10).value (data) ->
      assert.deepEqual data, [charRange(10), charRange(10, 20)]
      done()
    .run assert.ifError

  it 'outputs all items if n is greater than the number of items in the stream', (done) ->
    _(charRange 5).stream().batch(6).value (data) ->
      assert.deepEqual data, [charRange(5)]
      done()
    .run assert.ifError

  it 'outputs any items it has if the input stream ends', (done) ->
    _(charRange 13).stream().batch(10).value (data) ->
      assert.deepEqual data, [charRange(10), charRange(10, 13)]
      done()
    .run assert.ifError

  it 'outputs an empty array for an empty stream', (done) ->
    _([]).stream().batch(10).value (data) ->
      assert.deepEqual data, []
      done()
    .run assert.ifError

