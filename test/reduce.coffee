assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.reduce', ->

  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  it 'works with an empty stream with base 0', (done) ->
    _([]).stream().reduce
      base: 0
      fn: (count, item) -> count += 1
    .run (err, data) ->
      assert.deepEqual data, [0]
      assert.ifError err
      done()

  it 'works on numbers', (done) ->
    _([1, 2, 3]).stream().reduce({fn: ((a,b) -> a + b), base: 0}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [6]
      done()

  it 'works on objects', (done) ->
    _([{a: 1, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}]).stream().reduce(
      base: {}
      fn: (obj, new_obj) ->
        obj = { a: new_obj.a, b: [] } unless obj.b?
        obj.b.push new_obj.b
        obj
    ).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{ a: 1, b: [2,3,4] }]
      done()

  it 'works with multiple bases', (done) ->
    _([{a: 1, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}, {a: 2, b: 1}, {a: 3, b: 2}]).stream().reduce(
      base: () -> {}
      key: (new_obj) -> new_obj.a
      fn: (obj, new_obj) ->
        obj = { a: new_obj.a, b: [] } unless obj.b?
        obj.b.push new_obj.b
        obj
    ).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{a: 1, b: [2,3,4]}, {a: 2, b:[1]}, {a: 3, b: [2]}]
      done()
