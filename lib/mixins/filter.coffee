{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:filter'

module.exports = class Filter extends Transform
  constructor: (@options, @stream_opts) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    @options._async = true if @options.fn.length is 2
  _transform: (chunk, encoding, cb) =>
    if @options._async
      @options.fn chunk, (err, result) =>
        return cb err if err
        @push chunk if result
        cb()
    else
      @push chunk if @options.fn chunk
      cb()

module.exports =
  filter: (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new Filter options, stream_opts)
