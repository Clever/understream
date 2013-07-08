{Transform} = require 'readable-stream'
_      = require 'underscore'
debug  = require('debug') 'us:map'

class Map extends Transform
  constructor: (@stream_opts, @options) ->
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

module.exports = (Understream) ->
  Understream.mixin Map, 'map'
