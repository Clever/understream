assert = require 'assert'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
{Readable} = require 'stream'

describe '_.stream', ->
  it 'ends the stream chain and returns the last stream in the chain', ->
    assert _([]).stream().stream() instanceof Readable
