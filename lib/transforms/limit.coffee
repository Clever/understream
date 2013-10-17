{Transform} = require 'stream'

class Limit extends Transform
  constructor: (stream_opts, @limit) ->
    super stream_opts
    @seen = 0
  _transform: (chunk, encoding, cb) =>
    @seen++
    return cb() if @seen > @limit
    cb null, chunk

module.exports = (Understream) ->
  Understream.mixin Limit, 'limit'
