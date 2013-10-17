{Transform} = require 'stream'

class Skip extends Transform
  constructor: (stream_opts, @skip) ->
    super stream_opts
    @seen = -1
  _transform: (chunk, encoding, cb) =>
    @seen++
    return cb() if @seen < @skip
    cb null, chunk

module.exports = (Understream) -> Understream.mixin Skip, 'skip'
