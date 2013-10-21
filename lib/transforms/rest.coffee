{Transform} = require 'stream'

module.exports = class Rest extends Transform
  constructor: (stream_opts, @rest=1) ->
    super stream_opts
    @seen = -1
  _transform: (chunk, encoding, cb) =>
    @seen++
    return cb() if @seen < @rest
    cb null, chunk
