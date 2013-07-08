{Transform} = require 'readable-stream'
_      = require 'underscore'
debug  = require('debug') 'us:progress'

# passthrough stream that reports progress
class Progress extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    _(@options).defaults { every: 1000, name: '.' }
    @value = []
    @cnt = 0
  _transform: (chunk, encoding, cb) =>
    unless ++@cnt % @options.every
      debug "#{@options.name} #{@cnt} #{@_writableState.length}"
    @push chunk
    cb()

module.exports = (Understream) ->
  Understream.mixin Progress, 'progress'
