{Readable, Writable, PassThrough} = require 'stream'
fs     = require('fs')
_      = require 'underscore'
debug  = require('debug') 'us'
domain = require 'domain'
{EventEmitter} = require 'events'

_.mixin isPlainObject: (obj) -> obj.constructor is {}.constructor

defaults = objectMode: true, highWaterMark: 1000

is_readable = (instance) ->
  instance? and
  _.isObject(instance) and
  instance instanceof EventEmitter and
  instance.pipe?

run_streams = (streams, cb) ->
  streams = [streams] unless _(streams).isArray()
  dmn = domain.create()
  _(streams).last().on 'finish', cb
  dmn.on 'error', cb
  dmn.add stream for stream in streams
  dmn

class ArrayStream extends Readable
  constructor: (@options, @arr, @index=0) ->
    super _(@options).extend objectMode: true
  _read: (size) =>
    debug "_read #{size} #{JSON.stringify @arr[@index]}"
    @push @arr[@index++] # Note: push(undefined) signals the end of the stream, so this just works^tm

class DevNull extends Writable
  constructor: -> super objectMode: true
  _write: (chunk, encoding, cb) => cb()

class Understream
  constructor: (head) -> @_streams = [head]
  defaults: (@_defaults) => @
  start_report: =>
    report = =>
      str = ''
      _(@_streams).each (stream) ->
        str += "#{stream.constructor.name}(#{stream._writableState?.length or ''} #{stream._readableState?.length or ''}) "
      console.log str
    @interval = setInterval report, 5000
  register_domain: (cb) =>
    handler = (err) =>
      clearInterval @interval if @interval
      cb err
    run_streams @_streams, handler
  toNull: (cb) =>
    @_streams.push new DevNull() if _(@_streams).last()._transform?
    @start_report()
    @register_domain cb
  toArray: (cb) =>
    result = []
    @batch Infinity
    batch_stream = _(@_streams).last()
    batch_stream.on 'finish', -> result = batch_stream._buffer
    @start_report()
    @register_domain (err) ->
      return cb err if err
      cb null, result
  value: (cb) => _(@_streams).last()
  pipe: (stream_instance) => # If you want to add an instance of a stream to the middle of your understream chain
    _(@_streams).last().pipe stream_instance
    @_streams.push stream_instance
    @

create_stream = (head) ->
  if _(head).isArray()
    new ArrayStream {}, head
  else if is_readable head
    head
  else if not head?
    null
  else
    throw new Error "Expected a stream or an array, received #{JSON.stringify head}"

_s = (stream) ->
  array = for own key, val of _s
    [key, val.bind(null, create_stream(stream))]
  _(array).object()
module.exports = _s
_s.chain = (stream) -> new Understream stream
_s.toNull = (stream, cb) -> run_streams stream, cb
_s.toArray = (stream, cb) ->
  result = []
  batch_stream = _s.batch stream, Infinity
  batch_stream.on 'finish', -> result = batch_stream._buffer
  run_streams batch_stream, (err) ->
    return cb err if err
    cb null, result
_s.mixin = (FunctionOrStreamKlass, name=(FunctionOrStreamKlass.name or Readable.name), fn=false) ->
  if _(FunctionOrStreamKlass).isPlainObject() # underscore-style mixins
    mixin_by_name klass, name for name, klass of FunctionOrStreamKlass
  else
    mixin_by_name FunctionOrStreamKlass, name, fn
mixin_by_name = (FunctionOrStreamKlass, name=(FunctionOrStreamKlass.name or Readable.name), fn=false) ->
  instance_from_args = (stream, args...) ->
    if fn
      # Allow mixing in of functions like through()
      instance = FunctionOrStreamKlass.call null, stream, args...
    else
      # If this is a class and argument length is < constructor length, prepend defaults to arguments list
      if args.length < FunctionOrStreamKlass.length
        args.unshift _(@_defaults or defaults).clone()
      else if args.length is FunctionOrStreamKlass.length
        _(args[0]).defaults @_defaults or defaults
      else
        throw new Error "Expected #{FunctionOrStreamKlass.length} or #{FunctionOrStreamKlass.length-1} arguments to #{name}, got #{args.length}"
      instance = new FunctionOrStreamKlass args...
  _s[name] = (stream, args...) ->
    stream = create_stream stream
    throw new Error "#{name} expectes stream" unless stream
    instance = instance_from_args stream, args...
    stream.pipe instance
    debug 'created', instance.constructor.name
    instance
  Understream::[name] = (args...) -> @pipe instance_from_args.call @, _(@_streams).last(), args...

_s.mixin _(["#{__dirname}/transforms", "#{__dirname}/readables"]).chain()
  .map (dir) ->
    _(fs.readdirSync(dir)).map (filename) ->
      name = filename.match(/^([^\.]\S+)\.js$/)?[1]
      return unless name # Exclude hidden files
      [name, require("#{dir}/#{filename}")]
  .flatten(true)
  .object().value()
