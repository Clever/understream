{Readable} = require 'stream'
_      = require 'underscore'
debug  = require('debug') 'us:range'

class Range extends Readable
  constructor: (@start, @stop, @step, @stream_opts) ->
    # must be in objectMode since not producing strings or buffers
    super _(@stream_opts or {}).extend objectMode: true
    @size = Math.max Math.ceil((@stop - @start) / @step), 0
  _read: (size) =>
    return @push() unless @size
    @push @start
    @start += @step
    @size  -= 1

module.exports =
  range: (start, stop, step, stream_opts) ->
    if arguments.length <= 1
      # did not specify stop and step, maybe not even start
      stop = start or 0
      start = 0
    step = arguments[2] or 1
    new Range start, stop, step, stream_opts
