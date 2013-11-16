{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:invoke'

# TODO: support args (might be different than underscore API due to arg length logic in lib/understream)
class Where extends Transform
  constructor: (@attrs, @stream_opts) ->
    super @stream_opts
  _transform: (chunk, encoding, cb) =>
    for key, val of @attrs
      return cb() if val isnt chunk[key]
    cb null, chunk

module.exports =
  where: (readable, attrs, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Where attrs, stream_opts)
