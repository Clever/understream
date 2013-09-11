{Transform} = require 'readable-stream'
_      = require 'underscore'
async  = require 'async'
debug  = require('debug') 'us:queue'
util   = require 'util'
timers = require 'timers'

nextTick = timers?.setImmediate or process.nextTick

class Queue extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    _(@options).defaults concurrency: 1000
    @q = async.queue (payload, cb) =>
      return cb() if @_err # Don't try to keep processing if we've errored
      @options.fn payload, (err, out) =>
        debug "received", out
        return cb() if @_err
        if err
          @end() # End the stream immediately if there's an error
          return cb @_err = err # Store this so that _flush has access to it
        @push out unless out is undefined
        cb()
    , @options.concurrency
  _docs_in_queue: => @q.length() + @q.running()
  _transform: (chunk, encoding, cb) =>
    # If the queue is full, we hold on to the callback to preserve backpressure
    async.whilst(
      => @_docs_in_queue() >= @options.concurrency
      (cb_w) => nextTick cb_w
      =>
        debug "pushing", chunk
        @q.push chunk
        cb()
    )
  _flush: (cb) =>
    if @_docs_in_queue() > 0
      @q.drain = => cb @_err
    else
      nextTick => cb @_err

module.exports = (Understream) ->
  Understream.mixin Queue, 'queue'
