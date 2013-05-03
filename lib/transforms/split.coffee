_      = require 'underscore'
debug  = require('debug') 'us:split'
Transform = require 'readable-stream/transform'

class Split extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { sep: @options } if _(@options).isString() or @options instanceof RegExp
    @leftover = ''
  _flush: (cb) =>
    @push @leftover
    cb()
  _transform: (chunk, encoding, cb) =>
    str = @leftover + chunk.toString()
    splits = str.split @options.sep
    @leftover = splits.pop()
    @push split for split in splits
    cb()

module.exports = (Understream) ->
  Understream.mixin Split, 'split'
