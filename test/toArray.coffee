assert = require 'assert'
_s     = require "#{__dirname}/../index"

describe '_s.toArray', ->
  it 'turns a readable stream into an array', ->
    arr_in = ['a', 'b', 'c', 'd']
    readable = _s.fromArray arr_in
    _s.toArray readable, (err, arr_out) ->
      assert.ifError err
      assert.deepEqual arr_in, arr_out
