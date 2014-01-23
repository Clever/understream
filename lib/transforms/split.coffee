_      = require 'underscore'
debug  = require('debug') 'us:split'
{Transform} = require 'stream'

module.exports = class Split extends Transform
  constructor: (@stream_opts, @options) ->
    delete @stream_opts.objectMode # must take in strings or buffers
    super @stream_opts
    @_readableState.objectMode = true
    @options = { sep: @options } if _(@options).isString() or @options instanceof RegExp
    if not @options?.sep?
      throw new Error("Split requires separator")
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
