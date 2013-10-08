{Duplex} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:file'
fs = require 'fs'

class File extends Duplex
  constructor: (@stream_opts, @path, @options) ->
    super @stream_opts
    @on 'pipe', (source) =>
      (@source = source).unpipe(@).pipe fs.createWriteStream(@path, @options)
  pipe: (dest, options) =>
    if not @source
      @wrap fs.createReadStream(@path, @options)
      super dest, options
    else
      @source.pipe dest, options

module.exports = (Understream) ->
  Understream.mixin File, 'file'
