{Readable, Writable, PassThrough, Transform} = require 'stream'
fs     = require('fs')
_      = require 'underscore'
debug  = require('debug') 'us'
domain = require 'domain'
{EventEmitter} = require 'events'

_.mixin isPlainObject: (obj) -> obj.constructor is {}.constructor

# Wraps a stream's _transform method in a domain, catching any thrown errors
# and re-emitting them from the stream.
domainify = (stream) ->
  if stream instanceof Transform
    dmn = domain.create()
    stream._transform = dmn.bind stream._transform.bind stream
    dmn.on 'error', (err) ->
      dmn.dispose()
      stream.emit 'error', err

is_readable = (instance) ->
  instance? and
  _.isObject(instance) and
  instance instanceof EventEmitter and
  instance.pipe? and
  (instance._read? or instance.read? or instance.readable)

state_to_string = (state) ->
  if state?
    (state.length or '') + (if state.objectMode then 'o' else 'b')
  else ''

to_report_string = (stream) -> _([
  state_to_string stream._writableState
  stream.constructor.name
  stream._extra_report_string?()
  state_to_string stream._readableState
]).compact().join(' ')

add_reporter = (streams) ->
  report = -> console.log _(streams).map(to_report_string).join(' | ')
  interval = setInterval report, 5000
  _(streams).each (stream) -> stream.on 'error', -> clearInterval interval
  _(streams).last().on 'finish', -> clearInterval interval

pipe_streams_together = (streams...) ->
  return if streams.length < 2
  streams[i].pipe streams[i + 1] for i in [0..streams.length - 2]

# Based on: http://stackoverflow.com/questions/17471659/creating-a-node-js-stream-from-two-piped-streams
# The version there was broken and needed some changes, we just kept the concept of using the 'pipe'
# event and overriding the pipe method
class StreamCombiner extends PassThrough
  constructor: (streams...) ->
    super objectMode: true
    @head = streams[0]
    @tail = streams[streams.length - 1]
    pipe_streams_together streams...
    @on 'pipe', (source) => source.unpipe(@).pipe @head
  pipe: (dest, options) => @tail.pipe dest, options

class ArrayStream extends Readable
  constructor: (@options, @arr, @index=0) ->
    super _(@options).extend objectMode: true
  _read: (size) =>
    debug "_read #{size} #{JSON.stringify @arr[@index]}"
    @push @arr[@index++] # Note: push(undefined) signals the end of the stream, so this just works^tm

class DevNull extends Writable
  constructor: -> super objectMode: true
  _write: (chunk, encoding, cb) => cb()

module.exports = class Understream
  constructor: (head) ->
    @_defaults = highWaterMark: 1000, objectMode: true
    head = new ArrayStream {}, head if _(head).isArray()
    if is_readable head
      @_streams = [head]
    else if not head?
      @_streams = []
    else
      throw new Error 'Understream expects a readable stream, an array, or nothing'

  defaults: (@_defaults) => @
  run: (cb) =>
    throw new Error 'Understream::run requires an error handler' unless _(cb).isFunction()
    # If the callback has arity 2, assume that they want us to aggregate all results in an array and
    # pass that to the callback.
    if cb.length is 2
      result = []
      @batch Infinity
      batch_stream = _(@_streams).last()
      batch_stream.on 'finish', -> result = batch_stream._buffer
    # If the final stream is Readable, attach a dummy writer to receive its output
    # and alleviate pressure in the pipe
    @_streams.push new DevNull() if is_readable _(@_streams).last()
    handler = (err) =>
      if cb.length is 1
        cb err
      else
        cb err, result
    _(@_streams).last().on 'finish', handler
    # Catch any errors thrown emitted by a stream with a handler
    pipeline = _.flatten _(@_streams).map (stream) -> stream._pipeline?() or [stream]
    add_reporter pipeline
    _.each pipeline, (stream) ->
      domainify stream
      stream.on 'error', handler
    debug 'running'
    pipe_streams_together @_streams...
    @
  readable: => # If you want to get out of understream and access the raw stream
    pipe_streams_together @_streams...
    _.extend _.last(@_streams), _pipeline: => @_streams
  duplex: =>
    _.extend new StreamCombiner(@_streams...), _pipeline: => @_streams
  stream: => @readable() # Just an alias for compatibility purposes
  pipe: (stream_instance) => # If you want to add an instance of a stream to the middle of your understream chain
    @_streams.push stream_instance
    @
  @mixin: (FunctionOrStreamKlass, name=(FunctionOrStreamKlass.name or Readable.name), fn=false) ->
    if _(FunctionOrStreamKlass).isPlainObject() # underscore-style mixins
      @_mixin_by_name klass, name for name, klass of FunctionOrStreamKlass
    else
      @_mixin_by_name FunctionOrStreamKlass, name, fn
  @_mixin_by_name: (FunctionOrStreamKlass, name=(FunctionOrStreamKlass.name or Readable.name), fn=false) ->
    Understream::[name] = (args...) ->
      if fn
        # Allow mixing in of functions like through()
        instance = FunctionOrStreamKlass.apply null, args
      else
        # If this is a class and argument length is < constructor length, prepend defaults to arguments list
        if args.length < FunctionOrStreamKlass.length
          args.unshift _(@_defaults).clone()
        else if args.length is FunctionOrStreamKlass.length
          _(args[0]).defaults @_defaults
        else
          throw new Error "Expected #{FunctionOrStreamKlass.length} or #{FunctionOrStreamKlass.length-1} arguments to #{name}, got #{args.length}"
        instance = new FunctionOrStreamKlass args...
      @pipe instance
      debug 'created', instance.constructor.name, @_streams.length
      @
  # For backwards compatibility and easier mixing in to underscore
  @exports: -> stream: (head) => new @ head

Understream.mixin _(["#{__dirname}/transforms", "#{__dirname}/readables"]).chain()
  .map (dir) ->
    _(fs.readdirSync(dir)).map (filename) ->
      name = filename.match(/^([^\.]\S+)\.js$/)?[1]
      return unless name # Exclude hidden files
      [name, require("#{dir}/#{filename}")]
  .flatten(true)
  .object().value()
