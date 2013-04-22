{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:progress'

# passthrough stream that reports progress
class Progress extends Transform
  constructor: (@options) ->
    _(@options).defaults { maxWrites: 200, objectMode: true, every: 1000, name: '.' }
    @value = []
    @cnt = 0
    super @options
  _transform: (chunk, encoding, cb) =>
    unless ++@cnt % @options.every
      debug "#{@options.name} #{@cnt} #{@_writableState.length}"
    @push chunk
    cb()

module.exports = (Understream) ->
  Understream.mixin Progress, 'progress'
