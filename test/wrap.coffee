assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
OldReadable = require 'readable-stream'
{Readable} = require 'stream'
unless Readable? then Readable = OldReadable # for node < v0.10

describe '_.stream', ->

  it 'wraps a Readable stream instance', (done) ->
    input = ['a', 'b', 'c']
    rs = new OldReadable objectMode: true
    rs.push item for item in input
    rs.push null
    _(rs).stream().value (result) ->
      assert.deepEqual input, result
      done()
    .run assert.ifError

  it 'wraps an object implementing the Readable stream interface', (done) ->
    input = ['a', 'b', 'c']
    rs = new Readable objectMode: true
    rs.push item for item in input
    rs.push null
    _(rs).stream().value (result) ->
      assert.deepEqual input, result
      done()
    .run assert.ifError
