{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:each'

class Reduce extends Transform
  constructor: (@options) ->
    # TODO @options._async = _(@options).isFunction and @options.fn.length is 2
    super _(@options).extend { objectMode: true, highWaterMark: 1000 }
    @_val = @options.base
  _flush: (cb) =>
    @push @_val
    cb()
  _transform: (chunk, encoding, cb) =>
    @_val = @options.fn @_val, chunk
    cb()

module.exports = (Understream) ->
  Understream.mixin Reduce, 'reduce'
