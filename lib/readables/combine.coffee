{PassThrough} = require 'stream'
_ = require 'underscore'
{is_readable} = require '../helpers'

# Combines the output of two Readable streams into one Readable stream. The
# items from each input stream will stay in order, but they may be in any order
# relative to items from the other input stream.
module.exports = class Combine
  constructor: (streams) ->
    throw new Error 'Expected Readable streams' unless _(streams).all is_readable
    output = new PassThrough objectMode: _(streams).any (stream) -> stream._readableState.objectMode
    cb = _.after streams.length, -> output.end()
    _(streams).each (stream) ->
      stream.on 'end', cb
      stream.pipe output, end: false
    return output
