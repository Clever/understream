_ = require 'underscore'
{Transform} = require 'stream'

module.exports = class Flatten extends Transform
  constructor: (stream_opts, @shallow=false) -> super stream_opts
  _transform: (chunk, enc, cb) =>
    return cb null, chunk unless _(chunk).isArray()
    els = if @shallow then chunk else _(chunk).flatten()
    @push el for el in els
    cb()
