{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:invoke'

# TODO: support args (might be different than underscore API due to arg length logic in lib/understream)
class Where extends Transform
  constructor: (@stream_opts, @attrs) ->
    super @stream_opts
  _transform: (chunk, encoding, cb) =>
    for key, val of @attrs
      return cb() if val isnt chunk[key]
    cb null, chunk

module.exports = (Understream) -> Understream.mixin Where
