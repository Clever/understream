_ = require 'underscore'
assert = require 'assert'
_s = require "#{__dirname}/../index"

describe 'wrapped', ->
  INPUT = [1..6]
  it 'supports chaining', (done) ->
    _s(INPUT).chain().map((num) -> num + 10).map((num) -> num - 9).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual _(INPUT).map((num) -> num + 1), data
      done()

  it 'supports wrapped', (done) ->
    stream = _s(INPUT).map (num) -> num + 10
    _s(stream).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual _(INPUT).map((num) -> num + 10), data
      done()

  it 'supports not wrapped', (done) ->
    stream = _s.map INPUT, (num) -> num + 10
    _s(stream).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual _(INPUT).map((num) -> num + 10), data
      done()

  it 'supports getting the stream out with value', (done) ->
    stream = _s(INPUT).chain().map((num) -> num + 10).value()
    _s(stream).toArray (err, data) ->
      assert.ifError err
      assert.deepEqual _(INPUT).map((num) -> num + 10), data
      done()
