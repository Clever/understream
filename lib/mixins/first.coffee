{Transform} = require 'stream'

module.exports = class First extends Transform
  constructor: (@first=1, stream_opts) ->
    super stream_opts
    @seen = 0
  _transform: (chunk, encoding, cb) =>
    @seen++
    if @seen > @first
      @push null
      return
    cb null, chunk

module.exports =
  first: (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new First options, stream_opts)
