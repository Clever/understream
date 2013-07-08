{Transform} = require 'writable-stream-parallel'
_      = require 'underscore'
csv    = require 'csv'
debug  = require('debug') 'us:csv'

# takes text, parses it into a json object
# usage: .csv({ from: { header: true, columns: true }})
class CSVParser extends Transform
  constructor: (@options) ->
    super _(@options).extend objectMode: true
    @on 'pipe', (readstream) =>
      return if readstream._csv
      readstream.unpipe @
      csv = csv().from.stream(readstream, @options)
      csv.on 'error', (err) =>
        console.log 'error', err
        #@emit('error', err) # todo error handling....
      csv._csv = true
      csv.pipe @
  _transform: (chunk, encoding, cb) => cb null, chunk

module.exports = (Understream) ->
  Understream.mixin CSVParser, 'csv'
