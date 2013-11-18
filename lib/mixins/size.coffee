{Transform} = require 'stream'
_      = require 'underscore'

class Size extends Transform
  constructor: (stream_opts) ->
    super stream_opts
    # force readable side into objectMode since we will be producing a number
    @_readableState.objectMode = true
    @size = 0
  _flush: (cb) =>
    @push @size
    cb()
  _transform: (chunk, encoding, cb) =>
    if @_writableState.objectMode
      @size += 1
    else
      @size += chunk.length
    cb()

module.exports =
  size: (readable, stream_opts={objectMode: readable._readableState.objectMode}) ->
    readable.pipe(new Size stream_opts)
