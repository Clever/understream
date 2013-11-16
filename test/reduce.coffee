assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_s     = require "#{__dirname}/../index"
test_helpers = require "#{__dirname}/helpers"

describe '_.reduce', ->
  # fails for node < v0.10.20 due to https://github.com/joyent/node/issues/6183
  return if test_helpers.node_major() is 10 and test_helpers.node_minor() < 20

  it 'works with an empty stream with base 0', (done) ->
    _s(_s.fromArray []).chain().reduce
      base: 0
      fn: (count, item) -> count += 1
    .toArray (err, data) ->
      assert.deepEqual data, [0]
      assert.ifError err
      done()

  it 'works on numbers', (done) ->
    _s(_s.fromArray [1, 2, 3]).chain().reduce({fn: ((a,b) -> a + b), base: 0}).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [6]
      done()

  it 'works on objects', (done) ->
    _s(_s.fromArray [{a: 1, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}]).chain().reduce(
      base: {}
      fn: (obj, new_obj) ->
        obj = { a: new_obj.a, b: [] } unless obj.b?
        obj.b.push new_obj.b
        obj
    ).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{ a: 1, b: [2,3,4] }]
      done()

  it 'works with multiple bases', (done) ->
    _s(_s.fromArray [{a: 1, b: 2}, {a: 1, b: 3}, {a: 1, b: 4}, {a: 2, b: 1}, {a: 3, b: 2}]).chain().reduce(
      base: () -> {}
      key: (new_obj) -> new_obj.a
      fn: (obj, new_obj) ->
        obj = { a: new_obj.a, b: [] } unless obj.b?
        obj.b.push new_obj.b
        obj
    ).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual data, [{a: 1, b: [2,3,4]}, {a: 2, b:[1]}, {a: 3, b: [2]}]
      done()
