{Transform} = require 'stream'

class Rest extends Transform
  constructor: (@rest=1, stream_opts) ->
    super stream_opts
    @seen = -1
  _transform: (chunk, encoding, cb) =>
    @seen++
    return cb() if @seen < @rest
    cb null, chunk

fn = (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
  readable.pipe(new Rest options, stream_opts)

module.exports =
  rest: fn
  tail: fn
  drop: fn
