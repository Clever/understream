{PassThrough} = require 'stream'
_ = require 'underscore'
{is_readable} = require '../helpers'

# Combines the output of several Readable streams into one Readable stream. The
# items from each input stream will stay in order, but they may be in any order
# relative to items from the other input streams.
module.exports = class Combine
  constructor: (stream_opts, streams) ->
    throw new Error 'Expected Readable streams' unless _(streams).all is_readable
    output = new PassThrough objectMode: _(streams).any (stream) -> stream._readableState.objectMode
    cb = _.after streams.length, -> output.end()
    # One for each stream that we pipe to output and three for piping output to another stream
    # Don't go any less than the default 10, though
    output.setMaxListeners Math.max streams.length + 3, 10
    _(streams).each (stream) ->
      stream.on 'end', cb
      stream.pipe output, end: false
    output.push null unless streams.length
    return output
