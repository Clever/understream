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
      @options.fn payload, (err, out) =>
        return cb err if err?
        @push out
        cb()
    , @options.concurrency
  _transform: (chunk, encoding, cb) =>
    async.whilst(
      => @q.length() >= @options.concurrency
      (cb_w) => nextTick cb_w
      =>
        @q.push chunk
        cb()
    )
  _flush: (cb) =>
    @q.drain = cb
    @q.drain() if @q.tasks.length is 0

module.exports = (Understream) ->
  Understream.mixin Queue, 'queue'
