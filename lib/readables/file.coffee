{Readable} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:file'
fs = require 'fs'

class File extends Readable
  constructor: (@stream_opts, path, options) ->
    super @stream_opts
    @wrap fs.createReadStream(path, options)

module.exports = (Understream) -> Understream.mixin File
