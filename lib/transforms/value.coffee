{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:value'

# like _.chain()....value(), this value kills the stream chain and returns an array of results
class Value extends Transform
  constructor: (@options) ->
    @options = { fn: @options } if _(@options).isFunction()
    @value = []
    super _(@options).extend objectMode: true
  _transform: (chunk, encoding, cb) =>
    @value.push chunk
    cb()
  _flush: (cb) =>
    cb()
    @options.fn @value

module.exports = (Understream) ->
  Understream.mixin Value, 'value'
