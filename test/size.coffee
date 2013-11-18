assert = require 'assert'
_s     = require "#{__dirname}/../index"
_      = require 'underscore'
crypto = require 'crypto'
{Readable} = require 'stream'

describe '_s.size', ->
  it 'emits the number of bytes in a stream', (done) ->
    r = new Readable()
    r._read = ->
    r.push crypto.randomBytes 256
    r.push crypto.randomBytes 256
    r.push null
    _s(r).chain().size().toArray (err, arr) ->
      assert.ifError err
      assert.deepEqual arr, [512]
      done()

  it 'emits the number of objects in an object stream', (done) ->
    _s(_s.fromArray [0, 1, 2, 3, 4]).chain().size().toArray (err, arr) ->
      assert.ifError err
      assert.deepEqual arr, [5]
      done()
