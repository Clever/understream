Readable = require 'readable-stream'
{Writable,Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
debug  = require('debug') 'us:join'
util = require 'util'

# lots of options here:
# 1. in memory sort merge
# 2. in memory hash merge
# 3. disk sort merge
# 4. disk hash merge
# sqlite has basically solved (1) and (3)
#
# supported options: (still todo)
# type: inner|cross
# engine: memory|sqlite

class HashAccumulator extends Writable
  constructor: (@options) ->
    @cache = {}
    int = setInterval () =>
      debug 'hash:cache size', _(@cache).keys().length
    , 1000
    @on 'finish', () =>
      debug "hash:finish size=#{_(@cache).keys().length}"
      clearInterval int
    @options.from.pipe @
    super _(@options).extend objectMode: true

  finished: () => @_writableState.finished

  store: (key, value) =>
    if not @cache[key]?
      @cache[key] = value
    else
      # object already here..., merge them
      for k, v of value
        @cache[key][k] = [@cache[key][k]] unless _(@cache[key][k]).isArray()
        @cache[key][k].push v

  _write: (chunk, encoding, cb) =>
    join_key = chunk[@options.on]
    if not join_key?
      cb new Error("Could not find join key '#{@options.on}': #{JSON.stringify chunk}")
    if _(@options.select).isString()
      @store join_key, _(chunk).pick(@options.select)
    else if _(@options.select).isArray()
      @store join_key, _.pick.apply(_, [chunk].concat(@options.select))
    else if _(@options.select).isObject()
      data = {}
      data[as] = chunk[field] for field, as of @options.select
      @store join_key, data
    else
      @store join_key, chunk
    cb()

class Join extends Transform
  constructor: (@options) ->
    # default to inner join
    for required in ['from', 'on']
      throw new Error "Join requires a '#{required}' argument" unless @options[required]
    throw new Error "'from' must be pipeable" unless _(@options.from.pipe).isFunction()
    @hash = new HashAccumulator @options
    super _(@options).extend objectMode: true

    # buffer data until the stream we're joining on finishes
    @_buffer = []
    @hash.on 'finish', () =>
      debug "performing join for #{@_buffer.length} buffered docs"
      _(@_buffer).each (spec, i) => @_do_join spec[0], spec[1]

  _do_join: (obj, cb) =>
    key = @options.as or @options.on
    return cb(null, obj) unless obj[key]? and match = @hash.cache[obj[key]] # TODO: error?
    if _(match).isArray()
      obj[k] = match
    else
      obj[k] = v for k, v of match
    cb null, obj

  _transform: (chunk, encoding, cb) =>
    # wait for join stream before joining
    if @hash.finished()
      @_do_join chunk, cb
    else
      @_buffer.push [chunk, cb]

module.exports = (Understream) ->
  Understream.mixin Join, 'join'
