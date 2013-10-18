_ = require 'underscore'
{Duplex} = require 'stream'

# TODO: error handling. exit code? stderr?
module.exports = class Process extends Duplex
  constructor: (@stream_opts, @process) ->
    super _(@stream_opts).extend(objectMode: false)
    @on 'pipe', (source) => source.unpipe(@).pipe @process.stdin
  pipe: (dest, options) => @process.stdout.pipe dest, options
