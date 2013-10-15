_ = require 'underscore'
{Transform} = require 'stream'

class Uniq extends Transform
  constructor: (@stream_opts, @sorted, @hash_fn) ->
    super @stream_opts
    if _(@sorted).isFunction()
      @hash_fn = @sorted
      @sorted = false
    else if _(@sorted).isObject() # Allow them to also pass in an options object
      @hash_fn = @sorted.hash_fn
      @sorted = @sorted.sorted
    @hash_fn ?= String
    @seen_map = {}
    @seen_arr = []
    @seen_cnt = 0
  _transform: (obj, encoding, cb) =>
    hash = @hash_fn obj
    send_obj = =>
      @seen_cnt++
      cb null, obj
    if @sorted
      return cb() if @seen_cnt and @seen_arr[@seen_cnt - 1] is hash
      @seen_arr.push hash
      send_obj()
    else
      return cb() if @seen_map[hash]
      @seen_map[hash] = true
      send_obj()

module.exports = (Understream) ->
  Understream.mixin Uniq, 'uniq'
