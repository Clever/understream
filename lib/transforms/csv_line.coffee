{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
csv    = require 'csv'
debug  = require('debug') 'us:csv'

# processes text line by line
# usage: .csv({ columns: true })
class CSVLineParser extends Transform
  constructor: (@options) ->
    super _(@options).extend objectMode: true
  _transform: (chunk, encoding, cb) =>
    csv().from.string(chunk, @options).once 'record', (parsed) =>
      if _(@options.columns).isArray()
        cb null, parsed
      else if @options.columns # this is the header row
        @options.columns = _(parsed).map((col) -> col.trim())
        cb()
      else
        cb null, parsed
    .on 'error', (err) =>
      console.log 'ERROR', err
      cb() # TODO error handling

module.exports = (Understream) ->
  Understream.mixin CSVLineParser, 'csv_line'
