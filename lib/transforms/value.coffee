{Transform} = require 'readable-stream'
_      = require 'underscore'
debug  = require('debug') 'us:value'

# like _.chain()....value(), this value kills the stream chain and returns an array of results
class Value extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    @value = []
  _transform: (chunk, encoding, cb) =>
    @value.push chunk
    cb()
  _flush: (cb) =>
    cb()
    @options.fn @value

module.exports = (Understream) ->
  Understream.mixin Value, 'value'
