{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
csv    = require 'csv'
debug  = require('debug') 'us:csv'

# processes text line by line
# usage: .csv({ columns: true })
class CSVLineParser extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
  _transform: (chunk, encoding, cb) =>
    return cb() unless chunk.length # ignore blank lines
    csv().from.string(chunk, @options)
    .on('error', (err) ->
      # todo allow for error recovery
      cb())
    .once 'record', (parsed) =>
      if _(@options.columns).isArray()
        cb null, parsed
      else if @options.columns # this is the header row
        @options.columns = _(parsed).map((col) -> col.trim())
        cb()
      else
        cb null, parsed

module.exports = (Understream) ->
  Understream.mixin CSVLineParser, 'csv_line'
