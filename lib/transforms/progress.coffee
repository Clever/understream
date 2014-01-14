{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:progress'

# passthrough stream that reports progress
module.exports = class Progress extends Transform
  constructor: (@stream_opts, @options) ->
    # In order to have as little effect as possible on performance, this stream
    # shouldn't buffer any data, so set highWaterMark to 0.
    super _.extend @stream_opts, highWaterMark: 0
    _(@options).defaults { every: 1000, name: '.' }
    @value = []
    @cnt = 0
  _transform: (chunk, encoding, cb) =>
    unless ++@cnt % @options.every
      debug "#{@options.name} #{@cnt} #{@_writableState.length}"
    @push chunk
    cb()
