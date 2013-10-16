{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:filter'

class Filter extends Transform
  constructor: (@stream_opts, @options) ->
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

module.exports = (Understream) -> Understream.mixin Filter
