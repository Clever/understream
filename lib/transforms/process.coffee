_ = require 'underscore'
{Duplex} = require 'stream'

# TODO: do something with stderr
module.exports = class Process extends Duplex
  constructor: (@stream_opts, @process) ->
    super _(@stream_opts).extend(objectMode: false)
    @on 'pipe', (source) => source.unpipe(@).pipe @process.stdin
    @process.on 'exit', (code, signal) =>
      return if code is 0 # Do nothing on success
      if code
        @emit 'error', new Error "exited with code #{code}"
      else
        @emit 'error', new Error "killed by signal #{signal}"
  pipe: (dest, options) => @process.stdout.pipe dest, options
  _extra_report_string: ->
    "stdin:#{@process.stdin._writableState.length}" +
    " pid:#{@process.pid}" +
    " stdout:#{@process.stdout._readableState.length}"
