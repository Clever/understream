_      = require 'underscore'
debug  = require('debug') 'us:split'
Transform = require 'readable-stream/transform'

class Split extends Transform
  constructor: (@stream_opts, @options) ->
    delete @stream_opts.objectMode # must take in strings or buffers
    super @stream_opts
    if not @options? or
    not (_(@options).isString() or @options instanceof RegExp or _(@options).isObject())
      throw new Error("Split requires separator")
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
