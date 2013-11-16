_ = require 'underscore'
{Transform} = require 'stream'

class SortedUniq extends Transform
  constructor: (@hash_fn, stream_opts) ->
    super stream_opts
    @last = null
  _transform: (obj, encoding, cb) =>
    hash = @hash_fn obj
    return cb() if @last? and @last is hash
    @last = hash
    cb null, obj

class UnsortedUniq extends Transform
  constructor: (@hash_fn, stream_opts) ->
    super stream_opts
    @seen = {}
  _transform: (obj, encoding, cb) =>
    hash = @hash_fn obj
    return cb() if @seen[hash]
    @seen[hash] = true
    cb null, obj

class Uniq
  constructor: (sorted, hash_fn, stream_opts) ->
    if _(sorted).isFunction() # For underscore-style arguments
      hash_fn = sorted
      sorted = false
    else if _(sorted).isObject() # Allow them to also pass in an options object
      hash_fn = sorted.hash_fn
      sorted = sorted.sorted
    hash_fn ?= String
    return new (if sorted then SortedUniq else UnsortedUniq) hash_fn, stream_opts

fn = (readable, sorted, hash_fn, stream_opts={objectMode:readable._readableState.objectMode}) ->
  readable.pipe(new Uniq sorted, hash_fn, stream_opts)

module.exports =
  uniq: fn
  unique: fn
