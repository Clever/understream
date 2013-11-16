_ = require 'underscore'
{Transform} = require 'stream'

class Flatten extends Transform
  constructor: (@shallow=false, stream_opts) -> super stream_opts
  _transform: (chunk, enc, cb) =>
    return cb null, chunk unless _(chunk).isArray()
    els = if @shallow then chunk else _(chunk).flatten()
    @push el for el in els
    cb()

module.exports =
  flatten: (readable, shallow, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Flatten shallow, stream_opts)
