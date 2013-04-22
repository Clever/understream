Readable = require 'readable-stream'
_      = require 'underscore'
debug  = require('debug') 'us:file'
fs = require 'fs'

class File extends Readable
  constructor: (path) ->
    super { highWaterMark: 1000 }
    @wrap fs.createReadStream(path)

module.exports = (Understream) ->
  Understream.mixin File, 'file'
