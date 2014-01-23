assert = require 'assert'
_     = require 'underscore'
Understream = require "#{__dirname}/../index"
{Readable} = require 'stream'

describe '_.stream', ->
  it 'ends the stream chain and returns the last stream in the chain', ->
    assert new Understream([]).stream() instanceof Readable
