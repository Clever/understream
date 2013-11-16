{Transform} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:reduce'

class Reduce extends Transform
  constructor: (@options, @stream_opts) ->
    super @stream_opts
    # TODO @options._async = _(@options).isFunction and @options.fn.length is 2
    if @options.key?
      @_val = {}
    else
      @_val = _(@options).result 'base'
  _flush: (cb) =>
    if @options.key?
      @push val for val in _(@_val).values()
    else
      @push @_val
    cb()
  _transform: (chunk, encoding, cb) =>
    if @options.key?
      key = @options.key chunk
      @_val[key] ?= _(@options).result 'base'
      @_val[key] = @options.fn @_val[key], chunk
    else
      @_val = @options.fn @_val, chunk
    cb()

fn = (readable, options, stream_opts={objectMode:readable._readableState.objectMode}) ->
  readable.pipe(new Reduce options, stream_opts)

module.exports =
  reduce: fn
  inject: fn
  foldl: fn
