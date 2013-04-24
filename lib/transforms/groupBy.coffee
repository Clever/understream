{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:each'

class GroupBy extends Transform
  constructor: (@options) ->
    @options = { fn: @options } if _(@options).isFunction() or _(@options).isString()
    # TODO @options._async = _(@options).isFunction and @options.fn.length is 2
    super _(@options).extend { objectMode: true, highWaterMark: 1000 }
    @_buffer = []
  _flush: (cb) =>
    val = _(@_buffer).groupBy(@options.fn)
    @_buffer = null # i don't trust gc
    @push val
    cb()
  _transform: (chunk, encoding, cb) =>
    @_buffer.push chunk
    cb()

module.exports = (Understream) ->
  Understream.mixin GroupBy, 'groupBy'
