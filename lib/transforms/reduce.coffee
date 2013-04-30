{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:each'

class Reduce extends Transform
  constructor: (@stream_opts, @options) ->
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

module.exports = (Understream) ->
  Understream.mixin Reduce, 'reduce'
