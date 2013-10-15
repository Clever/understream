_ = require 'underscore'
{Transform} = require 'stream'

class SortedUniq extends Transform
  constructor: (@stream_opts, @hash_fn) ->
    super @stream_opts
    @seen = []
    @seen_cnt = 0
  _transform: (obj, encoding, cb) =>
    hash = @hash_fn obj
    return cb() if @seen.length and _(@seen).last() is hash
    @seen.push hash
    cb null, obj

class UnsortedUniq extends Transform
  constructor: (@stream_opts, @hash_fn) ->
    super @stream_opts
    @seen = {}
  _transform: (obj, encoding, cb) =>
    hash = @hash_fn obj
    return cb() if @seen[hash]
    @seen[hash] = true
    cb null, obj

class Uniq
  constructor: (stream_opts, sorted, hash_fn) ->
    if _(sorted).isFunction() # For underscore-style arguments
      hash_fn = sorted
      sorted = false
    else if _(sorted).isObject() # Allow them to also pass in an options object
      hash_fn = sorted.hash_fn
      sorted = sorted.sorted
    hash_fn ?= String
    return new (if sorted then SortedUniq else UnsortedUniq) stream_opts, hash_fn

module.exports = (Understream) ->
  Understream.mixin Uniq, 'uniq'
