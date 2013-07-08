{Writable} = require 'readable-stream'
Readable = require 'readable-stream'
fs     = require('fs')
_      = require 'underscore'
debug  = require('debug') 'us'
domain = require 'domain'

# apply() for constructors
construct = (constructor, args) ->
  F = -> constructor.apply this, args
  F.prototype = constructor.prototype
  new F

class ArrayStream extends Readable
  constructor: (@options, @arr, @index=0) ->
    super _(@options).extend objectMode: true
  _read: (size) =>
    debug "_read #{size} #{JSON.stringify @arr[@index]}"
    @push @arr[@index++] # note: push(null) signals the end of the stream, so this just works^tm

class DevNull extends Writable
  constructor: () -> super { objectMode: true }
  _write: (chunk, encoding, cb) => cb()

class Understream
  constructor: (@read_stream) ->
    @defaults = { highWaterMark: 1000, objectMode: true }
    if _(@read_stream).isArray()
      @read_stream = new ArrayStream {}, @read_stream
      @read_streams = [@read_stream]
    else if @read_stream instanceof Readable
      @read_streams = [@read_stream]
    else if not @read_stream?
      @read_streams = []
  defaults: (@defaults) =>
  run: (cb) =>
    throw new Error 'Understream::run requires an error handler' unless _(cb).isFunction()
    report = () =>
      str = ''
      _(@read_streams).each (stream) ->
        str += "#{stream.constructor.name}(#{stream._writableState?.length or ''} #{stream._readableState?.length or ''}) "
      console.log str
    interval = setInterval report, 5000
    # if the final stream is a transform, attach a dummy writer to receive its output
    # and alleviate pressure in the pipe
    if _(@read_streams).last()._transform?
      @read_streams.push(new DevNull())
    _(@read_streams).last().on 'finish', () ->
      clearInterval interval
      cb()
    dmn = domain.create()
    dmn.on 'error', (err) =>
      clearInterval interval
      cb err
    dmn.add stream for stream in @read_streams
    dmn.run =>
      debug 'running'
      return unless @read_streams.length > 1
      _([0..@read_streams.length-2]).each (i) =>
        debug 'piping', @read_streams[i]?.constructor.name, '-->', @read_streams[i+1]?.constructor.name
        @read_streams[i].pipe @read_streams[i+1]
    @
  stream: () => @read_stream # if you want to get out of understream and access the raw stream
  @mixin: (FunctionOrReadableStreamKlass, name=ReadableStreamKlass.name, fn=false) ->
    Understream::[name] = () ->
      if fn
        # allow mixing in of functions like through()
        instance = FunctionOrReadableStreamKlass.apply null, arguments
      else
        # if this is a class and argument length is < constructor length, prepend defaults to arguments list
        args = _(arguments).toArray()
        if args.length < FunctionOrReadableStreamKlass.length
          args = [@defaults].concat args
        else if args.length is FunctionOrReadableStreamKlass.length
          _(args[0]).defaults @defaults
        else
          throw new Error "Expected #{FunctionOrReadableStreamKlass.length} or #{FunctionOrReadableStreamKlass.length-1} arguments to #{name}, got #{args.length}"
        instance = construct FunctionOrReadableStreamKlass, args
      @read_stream = instance
      @read_streams.push @read_stream
      debug 'created', @read_stream.constructor.name, @read_streams.length
      @

_(["#{__dirname}/transforms", "#{__dirname}/readables"]).each (dir) ->
  _(fs.readdirSync(dir)).each (filename) ->
    match = filename.match(new RegExp("^([^\\.]\\S+)\\\.js$")) # Exclude hidden files
    require("#{dir}/#{filename}") Understream if match

module.exports =
  exports: () ->
    { stream: (read_stream) -> new Understream(read_stream) }
  mixin: Understream.mixin
