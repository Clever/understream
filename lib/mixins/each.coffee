{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:each'

class Each extends Transform
  constructor: (@options, @stream_opts) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    @options._async = @options.fn.length is 2
  _transform: (chunk, encoding, cb) =>
    if @options._async
      @options.fn chunk, (err) =>
        return cb err if err?
        @push chunk
        cb()
    else
      @options.fn chunk
      @push chunk
      cb()

module.exports =
  each: (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Each options, stream_opts)
