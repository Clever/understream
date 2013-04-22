{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:each'

class Each extends Transform
  constructor: (@options) ->
    @options = { fn: @options } if _(@options).isFunction()
    @options._async = @options.fn.length is 2
    super _(@options).extend { objectMode: true, highWaterMark: 1000 }
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

module.exports = (Understream) ->
  Understream.mixin Each, 'each'
