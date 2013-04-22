{Writable,Transform} = require 'writable-stream-parallel'
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
    # @emit 'end' if @arr.length is @index
  _read: (size) =>
    debug "_read #{size} #{JSON.stringify @arr[@index]}"
    @push @arr[@index++] # note: push(null) signals the end of the stream, so this just works^tm

class DevNull extends Writable
  constructor: () -> super { objectMode: true }
  _write: (chunk, encoding, cb) => cb()

class Understream
  constructor: (@read_stream) ->
    if _(@read_stream).isArray()
      @read_stream = new ArrayStream {}, @read_stream
      @read_streams = [@read_stream]
    else if not @read_stream?
      @read_streams = []
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
    dmn.on 'error', cb
    dmn.add stream for stream in @read_streams
    dmn.run =>
      debug 'running'
      return unless @read_streams.length > 1
      _([0..@read_streams.length-2]).each (i) =>
        debug 'piping', @read_streams[i]?.constructor.name, '-->', @read_streams[i+1]?.constructor.name
        @read_streams[i].pipe @read_streams[i+1]
    @
  stream: () => @read_stream # if you want to get out of understream and access the raw stream
  @mixin: (ReadableStreamKlass, name=ReadableStreamKlass.name) ->
    Understream::[name] = () ->
      _(arguments[0]).extend { highWaterMark: 1000 }
      instance = construct ReadableStreamKlass, arguments
      @read_stream = instance
      @read_streams.push @read_stream
      debug 'created', @read_stream.constructor.name, @read_streams.length
      @

_(fs.readdirSync("#{__dirname}/transforms")).each (transform) ->
  ext = if process.env.TEST_UNDERSTREAM_COV then 'js' else 'coffee'
  match = transform.match(new RegExp("^([^\\.]\\S+)\\\.#{ext}$")) # Exclude hidden files and non-coffee files
  require("#{__dirname}/transforms/#{transform}") Understream if match

_(fs.readdirSync("#{__dirname}/readables")).each (readable) ->
  ext = if process.env.TEST_UNDERSTREAM_COV then 'js' else 'coffee'
  match = readable.match(new RegExp("^([^\\.]\\S+)\\\.#{ext}$")) # Exclude hidden files and non-coffee files
  require("#{__dirname}/readables/#{readable}") Understream if match

_(fs.readdirSync("#{__dirname}/writables")).each (readable) ->
  ext = if process.env.TEST_UNDERSTREAM_COV then 'js' else 'coffee'
  match = readable.match(new RegExp("^([^\\.]\\S+)\\\.#{ext}$")) # Exclude hidden files and non-coffee files
  require("#{__dirname}/writables/#{readable}") Understream if match

module.exports =
  exports: () ->
    { stream: (read_stream) -> new Understream(read_stream) }
  mixin: Understream.mixin
