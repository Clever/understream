assert = require 'assert'
_s     = require "#{__dirname}/../index"

describe '_s.fromString', ->
  it 'turns a string into a readable stream', ->
    str_in = 'abcd'
    readable = _s.fromString str_in
    # TODO: readable = _s('abcd').fromString()
    assert readable._readableState.objectMode, "Expected fromArray to produce an objectMode stream"
    str_out = ''
    str_out += el while el = readable.read()
    assert.equal str_in, str_out
