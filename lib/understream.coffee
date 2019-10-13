{Readable, Writable, PassThrough, Transform} = require 'stream'
fs     = require('fs')
_      = require 'underscore'
_.mixin require 'underscore.deep'
debug  = require('debug') 'us:'
domain = require 'domain'
{EventEmitter} = require 'events'
{is_readable, DEFAULT_MAX_LISTENERS} = require './helpers'

# Adds a listener to an EventEmitter but first bumps the max listeners limit
# for that emitter. The limit is meant to prevent memory leaks, so this should
# only be used when you're sure you're not creating a memory leak. Good luck
# convincing yourself you're safe...
add_listener_unsafe = (emitter, event, listener) ->
  if emitter._maxListeners?
    emitter.setMaxListeners emitter._maxListeners + 1
  else
    emitter._maxListeners = DEFAULT_MAX_LISTENERS + 1
  emitter.addListener event, listener

# Wraps a stream's _transform method in a domain, catching any thrown errors
# and re-emitting them from the stream.
domainify = (stream) ->
  if stream instanceof Transform
    dmn = domain.create()
    stream._transform = dmn.bind stream._transform.bind stream
    stream._flush = dmn.bind stream._flush.bind stream if stream._flush?
    dmn.once 'error', (err) ->
      dmn.exit()
      stream.emit 'error', err
    # Use .exit() instead of .dispose() because .dispose() was breaking the
    # tests. Something to look into at some point maybe... (-Jonah)
    add_listener_unsafe stream, 'end', -> dmn.exit()

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
  report = -> debug _(streams).map(to_report_string).join(' | ')
  interval = setInterval report, 5000
  _(streams).each (stream) -> add_listener_unsafe stream, 'error', -> clearInterval interval
  _(streams).last().on 'finish', -> clearInterval interval

# Given an array of streams, produces an array of all streams involved in the pipeline of any of
# those streams. To figure out what streams are involed in the pipeline, it calls each stream's
# _pipeline method, expecting it to return an array of all the streams besides itself that are part
# of its operation.
#
# For instance, the StreamCombiner stream below returns all the streams it is combining.
# The join stream returns the secondary stream it is joining from.
#
# This allows Understream to handle errors and report progress on streams it would otherwise not
# have any access to.
#
# If a stream does not implement _pipeline, the stream will be considered to have no other streams
# involved in its execution. If a stream does implement _pipeline, all streams returned by _pipeline
# will recursively be asked for their _pipeline.
pipeline_of_streams = (streams) ->
  _.flatten _(streams).map (stream) ->
    if stream._pipeline?
      # In old versions of Understream, _pipeline returned the stream. We defensively avoid
      # recursing on the stream itself to prevent infinite loops.
      pipeline_of_streams(_.without stream._pipeline(), stream).concat [stream]
    else
      [stream]

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
    @_pipeline = -> streams
  pipe: (dest, options) => @tail.pipe dest, options

class ArrayStream extends Readable
  constructor: (@options, @arr, @index=0) ->
    super _(@options).extend objectMode: true
  _read: (size) =>
    data = @arr[@index]
    if data is undefined
      @push null
      return
    debug "_read #{size} #{JSON.stringify data}"
    @push data
    @index += 1

class DevNull extends Writable
  constructor: -> super objectMode: true
  _write: (chunk, encoding, cb) -> cb()

module.exports = class Understream
  constructor: (head) ->
    @_defaults = highWaterMark: 20, objectMode: true
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
    handler = _.once (err) ->
      if cb.length is 1
        cb err
      else
        cb err, result
    _(@_streams).last().on 'finish', handler
    # Catch any errors thrown emitted by a stream with a handler
    pipeline = pipeline_of_streams @_streams
    add_reporter pipeline
    _.each pipeline, (stream) ->
      domainify stream
      add_listener_unsafe stream, 'error', handler
    debug 'running'
    pipe_streams_together @_streams...
    @
  readable: => # If you want to get out of understream and access the raw stream
    pipe_streams_together @_streams...
    [streams..., last] = @_streams
    _.extend last, _pipeline: -> streams
  duplex: => new StreamCombiner @_streams...
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

Understream.mixin _(["#{__dirname}/transforms", "#{__dirname}/readables"]).chain()
  .map (dir) ->
    _(fs.readdirSync(dir)).map (filename) ->
      name = filename.match(/^([^\.]\S+)\.js$/)?[1]
      return unless name # Exclude hidden files
      [name, require("#{dir}/#{filename}")]
  .flatten(true)
  .object().value()
