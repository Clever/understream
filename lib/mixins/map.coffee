{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:map'

class Map extends Transform
  constructor: (@options, @stream_opts) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    @options._async = @options.fn.length is 2
  _transform: (chunk, encoding, cb) =>
    debug "_transform #{JSON.stringify chunk}"
    if @options._async
      @options.fn chunk, (err, result) =>
        return cb err if err
        @push result
        cb()
    else
      @push @options.fn(chunk)
      cb()

module.exports =
  map: (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Map options, stream_opts)
