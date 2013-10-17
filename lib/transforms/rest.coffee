{Transform} = require 'stream'

class Rest extends Transform
  constructor: (stream_opts, @rest=1) ->
    super stream_opts
    @seen = -1
  _transform: (chunk, encoding, cb) =>
    @seen++
    return cb() if @seen < @rest
    cb null, chunk

module.exports = (Understream) -> Understream.mixin Rest, 'rest'
