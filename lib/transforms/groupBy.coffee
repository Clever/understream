{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:groupBy'

class GroupBy extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction() or _(@options).isString()
    # TODO @options._async = _(@options).isFunction and @options.fn.length is 2
    @_buffer = []
  _flush: (cb) =>
    val = _(@_buffer).groupBy(@options.fn)
    @_buffer = null # i don't trust gc
    if @options.unpack
      @push _.object([[k,v]]) for k, v of val
    else
      @push val
    cb()
  _transform: (chunk, encoding, cb) =>
    @_buffer.push chunk
    cb()

module.exports = (Understream) ->
  Understream.mixin GroupBy, 'groupBy'
