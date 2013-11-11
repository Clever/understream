{Transform} = require('stream')
_      = require 'underscore'
domain = require 'domain'

# Accumulates each group of `batchSize` items and outputs them as an array.
class Batch extends Transform
  constructor: (@batchSize, @stream_opts) ->
    super @stream_opts
    @_buffer = []
  _transform: (chunk, encoding, cb) =>
    if @_buffer.length < @batchSize
      @_buffer.push chunk
    else
      @push @_buffer
      @_buffer = [chunk]
    cb()
  _flush: (cb) =>
    @push @_buffer if @_buffer.length > 0
    cb()

module.exports =
  toArray: (readable, cb) ->
    dmn = domain.create()
    batch = new Batch Infinity, {objectMode: readable._readableState.objectMode}
    handler = (err) -> cb err, batch._buffer
    batch.on 'finish', handler
    dmn.on 'error', handler
    dmn.add readable
    dmn.add batch
    dmn.run -> readable.pipe batch
