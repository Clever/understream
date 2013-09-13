Readable = require 'readable-stream'
Writable = require 'readable-stream/writable'
{Transform} = require 'readable-stream'
_      = require 'underscore'
debug  = require('debug') 'us:join'
util = require 'util'
nextTick = require '../nextTick'

# If you want a quick overview of join semantics, check this out:
# http://www.codinghorror.com/blog/2007/10/a-visual-explanation-of-sql-joins.html

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

# @options.on specifies how to hash objects
# on: ['a'] => hash objects on 'a'
# on: ['a', {'c': 'd'}] =>
#   hash objects in "from" stream on 'a', 'd', objects in source stream on 'a', 'c'
hash_fn = (source, onn) ->
  (obj) ->
    _(onn).map((on_spec) =>
      key = on_spec
      if _(on_spec).isObject()
        key = _(on_spec).chain().pairs().flatten()[if source then 'first' else 'last']().value()
      val = obj[key]
      if not val?
        throw new Error "Could not find '#{key}': #{util.inspect obj}"
      val
    ).join '|'

class HashAccumulator extends Writable
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @cache = {}
    int = setInterval () =>
      debug 'hash:cache size', _(@cache).size()
    , 1000
    @on 'finish', () =>
      debug "hash:finish size=#{_(@cache).size()}"
      clearInterval int
    @options.from.pipe @

  finished: () => @_writableState.finished

  _write: (obj, encoding, cb) =>
    @_hash ?= hash_fn false, @options.on
    hash = @_hash obj
    if @cache[hash]?
      throw new Error "Duplicate object according to 'on'=#{util.inspect @options.on} prev_match=#{util.inspect @cache[hash]} current_match=#{util.inspect obj}"
    @cache[hash] = do_select @options.select, obj
    cb()

do_select = (spec, obj) ->
  # @options.select specifies what to pull out from this obj
  # select: ['a'] => just 'a'
  # select: [{'a':'a_'}, 'b'] => pull 'a' as 'a_', 'b' as itself
  data = {}
  if (not spec) or (not obj?)
    data = obj
  else
    _(spec).each (sel) =>
      if _(sel).isString()
        data[sel] = obj[sel]
      else
        data[as] = obj[key] for key, as of sel
  data

class HashJoin extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @hash = new HashAccumulator @stream_opts, @options

    # buffer data until the stream we're joining on finishes
    @_buffer = []
    @hash.on 'finish', () =>
      debug "performing join for #{@_buffer.length} buffered docs"
      _(@_buffer).each (spec, i) => @_do_join spec[0], spec[1]

  _do_join: (obj, cb) =>
    @_hash ?= hash_fn true, @options.on
    hash = @_hash obj
    match = @hash.cache[hash]
    if not match?
      switch @options.type
        when 'left' then return cb null, obj
        when 'inner', 'right' then return cb()
    else
      # there's a match, so copy over selected fields
      obj[k] = v for k, v of match
      cb null, obj

  _transform: (chunk, encoding, cb) =>
    # wait for join stream before joining
    if @hash.finished()
      @_do_join chunk, cb
    else
      @_buffer.push [chunk, cb]

class SortedMergeJoin extends Transform
  # This is a kind of tricky version of the usual merge algorithm since we want
  # to use a Transform stream. The instance itself will function as the left
  # stream.
  constructor: (stream_opts, {@right, @key, @type, @select}) ->
    @select = @select?.concat @key
    super stream_opts

  push: (arg) ->
    # push() still needs to support pushing null
    unless arg? then return super null
    [l, r] = arg
    if (@type is 'left' and l?) or
        (@type is 'right' and r?) or
        (@type is 'inner' and l? and r?) or
        (@type is 'outer')
      super _.extend {}, l, do_select(@select, r)

  # Since _transform is called each time there's a new left item
  # ready, and blocks the left stream until we call cb, we need to do all the
  # processing necessary for that item and then call cb.
  _transform: (chunk, enc, cb) ->
    next = -> nextTick cb
    l = chunk
    while (r = @right.read())?
      if l[@key] > r[@key]
        @push [null, r]
      else if l[@key] < r[@key]
        @push [l, null]
        # Put r back at the head of right so we can read it again next
        # _transform or in _flush
        @right.unshift r
        return next()
      else if l[@key] is r[@key]
        @push [l, r]
        return next()
    @push [l, null]
    next()

  # _flush is called when the stream is empty, so we need to also empty out the
  # right stream if there are any leftovers.
  _flush: (cb) ->
    @push [null, r] while (r = @right.read())?
    nextTick cb

class Join
  constructor: (@stream_opts, @options) ->
    #super @stream_opts
    # default to inner join
    for required in ['from', 'on']
      throw new Error "Join requires a '#{required}' argument" unless @options[required]
    _(@options).defaults { type: 'inner' }
    @options.on = [@options.on] unless _(@options.on).isArray()
    @options.select = [@options.select] if @options.select? and not _(@options.select).isArray()
    # todo: validate each @options.on is either a string or single {k:v}
    throw new Error "'from' must be pipeable" unless _(@options.from.pipe).isFunction()

    if @options.sorted
      return new SortedMergeJoin @stream_opts,
        right: @options.from
        key: @options.on
        type: @options.type
        select: @options.select
    else
      return new HashJoin @stream_opts, @options

module.exports = (Understream) ->
  Understream.mixin Join, 'join'
