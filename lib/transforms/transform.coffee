Transform = require('stream').Transform
_      = require 'underscore'
debug  = require('debug') 'us:custom'

# Creates a Transform stream using a given _transform function (and optionally,
# a given _flush function).
module.exports = class CustomTransform extends Transform
  constructor: (@stream_options, @_transform, flush) ->
    super @stream_options
    @_transform = _.bind @_transform, this
    @_flush = flush if flush?
