_              = require 'underscore'
debug          = require('debug') 'us'
domain         = require 'domain'
fs             = require 'fs'
{EventEmitter} = require 'events'
{PassThrough, Readable, Writable} = require 'readable-stream'

is_readable = (instance) ->
  instance? and
  _.isObject(instance) and
  instance instanceof EventEmitter and
  instance.pipe?

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

class Understream
  constructor: (head) ->
    @defaults = highWaterMark: 1000, objectMode: true
    head = new ArrayStream {}, head if _(head).isArray()
    if is_readable head
      @_streams = [head]
    else if not head?
      @_streams = []
    else
      throw new Error 'Understream expects a readable stream, an array, or nothing'

  defaults: (@defaults) =>
  run: (cb) =>
    throw new Error 'Understream::run requires an error handler' unless _(cb).isFunction()
    report = =>
      str = ''
      _(@_streams).each (stream) ->
        str += "#{stream.constructor.name}(#{stream._writableState?.length or ''} #{stream._readableState?.length or ''}) "
      console.log str
    interval = setInterval report, 5000
    # If the callback has arity 2, assume that they want us to aggregate all results in an array and
    # pass that to the callback.
    if cb.length is 2
      result = []
      @batch Infinity
      batch_stream = _(@_streams).last()
      batch_stream.on 'finish', -> result = batch_stream._buffer
    # If the final stream is a transform, attach a dummy writer to receive its output
    # and alleviate pressure in the pipe
    @_streams.push new DevNull() if _(@_streams).last()._transform?
    dmn = domain.create()
    handler = (err) =>
      clearInterval interval
      if cb.length is 1
        cb err
      else
        cb err, result
    _(@_streams).last().on 'finish', handler
    dmn.on 'error', handler
    dmn.add stream for stream in @_streams
    dmn.run =>
      debug 'running'
      pipe_streams_together @_streams...
    @
  readable: => # If you want to get out of understream and access the raw stream
    pipe_streams_together @_streams...
    @_streams[@_streams.length - 1]
  duplex: => new StreamCombiner @_streams...
  stream: => @readable() # Just an alias for compatibility purposes
  pipe: (stream_instance) => # If you want to add an instance of a stream to the middle of your understream chain
    @_streams.push stream_instance
    @
  @mixin: (FunctionOrStreamKlass, name=(FunctionOrStreamKlass.name or Readable.name), fn=false) ->
    Understream::[name] = (args...) ->
      if fn
        # Allow mixing in of functions like through()
        instance = FunctionOrStreamKlass.apply null, args
      else
        # If this is a class and argument length is < constructor length, prepend defaults to arguments list
        if args.length < FunctionOrStreamKlass.length
          args.unshift _(@defaults).clone()
        else if args.length is FunctionOrStreamKlass.length
          _(args[0]).defaults @defaults
        else
          throw new Error "Expected #{FunctionOrStreamKlass.length} or #{FunctionOrStreamKlass.length-1} arguments to #{name}, got #{args.length}"
        instance = new FunctionOrStreamKlass args...
      @pipe instance
      debug 'created', instance.constructor.name, @_streams.length
      @

_(["#{__dirname}/transforms", "#{__dirname}/readables"]).each (dir) ->
  _(fs.readdirSync(dir)).each (filename) ->
    return unless new RegExp("^([^\\.]\\S+)\\.js$").test filename # Exclude hidden files
    require("#{dir}/#{filename}") Understream

module.exports =
  exports: ->
    stream: (head) -> new Understream head
  mixin: Understream.mixin
