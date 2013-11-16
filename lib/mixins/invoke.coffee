{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:invoke'

# TODO: support args (might be different than underscore API due to arg length logic in lib/understream)
class Invoke extends Transform
  constructor: (@method, @stream_opts) ->
    super @stream_opts
  _transform: (chunk, encoding, cb) =>
    cb null, chunk[@method].apply(chunk)

module.exports =
  invoke: (readable, method, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Invoke method, stream_opts)
