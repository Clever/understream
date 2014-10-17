_ = require 'underscore'
{Duplex, PassThrough} = require 'stream'

# TODO: do something with stderr
module.exports = class Process extends Duplex
  constructor: (@stream_opts, @process) ->
    super _(@stream_opts).extend(objectMode: false)
    @on 'pipe', (source) => source.unpipe(@).pipe @process.stdin

    # The 'exit' event is sometimes emitted after the stdout stream has closed and sometimes it is
    # emitted before the stdout stream has closed. The 'close' event is always emitted after the
    # stdout stream has closed. We need to emit an error event BEFORE we close the output stream if
    # the process failed. To accomplish this, we create a PassThrough stream and pipe stdout through
    # it, and only close it when we've received the 'close' event from the process, first emitting
    # an error if the process failed.
    @out = new PassThrough()
    @process.stdout.pipe @out, end: false

    @process.on 'close', (code, signal) =>
      if code not in [null, 0] # Do nothing on success
        @emit 'error', new Error "exited with code #{code}"
      if signal isnt null
        @emit 'error', new Error "killed by signal #{signal}"
      @out.end()

  pipe: (dest, options) => @out.pipe dest, options
  _pipeline: => [@process.stdin, @process.stdout, @process.stderr, @out]
  _extra_report_string: ->
    "stdin:#{@process.stdin._writableState.length}" +
    " pid:#{@process.pid}" +
    " stdout:#{@process.stdout._readableState.length}"
