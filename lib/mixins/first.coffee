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

fn = (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
  readable.pipe(new First options, stream_opts)

module.exports =
  first: fn
  head: fn
  take: fn
