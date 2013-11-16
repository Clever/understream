{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:groupBy'

class GroupBy extends Transform
  constructor: (@options, @stream_opts) ->
    super @stream_opts
    @options = switch
      when _(@options).isFunction()
        {fn: @options}
      when _(@options).isString()
        key = @options
        {fn: (obj) -> obj[key]}
      else
        @options
    @options._async = _(@options.fn).isFunction() and @options.fn.length is 2
    @_buffer = {}
  _flush: (cb) =>
    if @options.unpack
      @push _.object([[k,v]]) for k, v of @_buffer
    else
      @push @_buffer
    @_buffer = null # i don't trust gc
    cb()
  _transform: (chunk, encoding, cb) =>
    add = (hash) =>
      @_buffer[hash] ?= []
      @_buffer[hash].push chunk
      cb()
    if not @options._async
      add @options.fn chunk
    else
      @options.fn chunk, (err, hash) =>
        return cb err if err
        add hash

module.exports =
  groupBy: (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
    readable.pipe(new GroupBy options, stream_opts)
