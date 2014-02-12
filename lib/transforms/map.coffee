{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:map'

module.exports = class Map extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    @options._async = @options.fn.length is 2
  _transform: (chunk, encoding, cb) =>
    debug "_transform #{JSON.stringify chunk}"
    if @options._async
      @options.fn chunk, (err, result) =>
        if err?
          return setImmediate -> cb err
        @push result
        setImmediate cb
    else
      @push @options.fn(chunk)
      setImmediate cb
