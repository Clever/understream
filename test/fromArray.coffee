assert = require 'assert'
_s     = require "#{__dirname}/../index"
_      = require 'underscore'

describe '_s.fromArray', ->
  it 'turns an array into a readable stream', ->
    arr = ['a', 'b', 'c', 'd']
    readable = _s.fromArray _(arr).clone() # we'll be modifying arr here
    # TODO: readable = _s(['a', 'b', 'c', 'd']).fromArray()
    assert readable._readableState.objectMode, "Expected fromArray to produce an objectMode stream"
    while el = readable.read()
      assert.equal el, arr.shift()
