{PassThrough} = require 'stream'
_ = require 'underscore'
{is_readable} = require './helpers'

# Combines the output of two Readable streams into one Readable stream. The
# items from each input stream will stay in order, but they may be in any order
# relative to items from the other input stream.
module.exports = (left, right) ->
  throw new Error 'Expected Readable streams' unless is_readable(left) and is_readable(right)
  output = new PassThrough objectMode:
    (left._readableState.objectMode or right._readableState.objectMode)
  cb = _.after 2, -> output.end()
  left.on 'end', cb
  left.pipe output, end: false
  right.on 'end', cb
  right.pipe output, end: false
  output
