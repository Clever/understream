{Transform} = require 'stream'
_      = require 'underscore'
async  = require 'async'
debug  = require('debug') 'us:queue'
util   = require 'util'

module.exports = class Queue extends Transform
  constructor: (@stream_opts, @options) ->
    super @stream_opts
    @options = { fn: @options } if _(@options).isFunction()
    _(@options).defaults concurrency: @stream_opts.highWaterMark or 10
    @q = async.queue (payload, cb) =>
      return setImmediate cb if @_err # Don't try to keep processing if we've errored
      @options.fn payload, (err, out) =>
        @_err ?= err if err
        return setImmediate cb if @_err
        @push out unless out is undefined
        setImmediate cb
    , @options.concurrency
  _docs_in_queue: => @q.length() + @q.running()
  _transform: (chunk, encoding, cb) =>
    # If the queue is full, we hold on to the callback to preserve backpressure
    async.whilst(
      => @_docs_in_queue() >= @options.concurrency
      (cb_w) -> setImmediate cb_w
      =>
        # If given an array, async.queue.push pushes each element. If chunk is
        # an array, we want it to be pushed as one item, so we wrap all chunks.
        @q.push [chunk]
        cb()
    )
  _flush: (cb) =>
    if @_docs_in_queue() > 0
      @q.drain = => cb @_err
    else
      setImmediate => cb @_err
