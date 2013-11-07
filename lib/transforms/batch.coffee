Transform = require('stream').Transform
_      = require 'underscore'
debug  = require('debug') 'us:batch'

# Accumulates each group of `batchSize` items and outputs them as an array.
module.exports = class Batch extends Transform
  constructor: (@stream_opts, @batchSize) ->
    super @stream_opts
    @_buffer = []
  _transform: (chunk, encoding, cb) =>
    if @_buffer.length < @batchSize
      @_buffer.push chunk
    else
      @push @_buffer
      @_buffer = [chunk]
    cb()
  _flush: (cb) =>
    @push @_buffer if @_buffer.length > 0
    cb()
  _extra_report_string: -> "#{@_buffer.length}"
