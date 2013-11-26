assert = require 'assert'
_      = require 'underscore'
_s     = require "#{__dirname}/../index"
domain = require 'domain'
{Transform} = require 'stream'

# We live in a world of libraries with various interfaces for communicating errors:
# 'sync-cb': lib(input, cb), cb is called synchronously with error as first argument
# 'async-cb': lib(input, cb), cb is called asynchronously with error as first argument
# 'sync-cb-throw': lib(input, cb), same as sync-cb, but sometimes throws w/o hitting cb
# 'async-cb-throw' lib(input, cb), same as async-cb, but sometimes throws w/o hitting cb
bad_lib_factory = (type) ->
  error = new Error "bad lib only works the first time you call it"
  error.from_bad_lib = true
  switch type
    when 'sync-cb'
      cnt = 0
      return (input, cb) ->
        if ++cnt is 0 then cb(null, input) else cb error
    when 'async-cb'
      cnt = 0
      return (input, cb) ->
        if ++cnt is 0
          setImmediate () -> cb(null, input) # don't release the zalgo
        else
          cb error
    when 'sync-cb-throw'
      cnt = 0
      return (input, cb) ->
        if ++cnt is 0 then cb(null, input) else throw error
    when 'async-cb-throw'
      cnt = 0
      return (input, cb) ->
        if ++cnt is 0
          setImmediate () -> cb null, input
        else
          setTimeout (() -> throw error), 500
    else throw new Error "Unknown lib type #{type}"

# When using a library within a stream you create, it is your responsibility to trap library errors
# and communicate errors back to users of your stream. Since streams communicate errors via an
# "error" event, it is up to you to funnel errors into this event.
best_practice_stream_factory = (bad_lib_type) ->
  bad_lib = bad_lib_factory bad_lib_type
  t = new Transform { objectMode: true }
  t._transform = (chunk, enc, cb) ->
    switch bad_lib_type
      when 'sync-cb'
        bad_lib chunk, cb
      when 'async-cb'
        bad_lib chunk, cb
      when 'sync-cb-throw'
        # OPINION: If a lib you're using presents a synchronous interface, use try/catch
        try
          bad_lib chunk, cb
        catch err
          cb err
      when 'async-cb-throw'
        # OPINION: If a lib you're using presents an asynchronous interface, yet still throws
        # errors (facepalm), wrap it in a domain:
        dmn = domain.create()
        dmn.run () ->
          bad_lib chunk, (err, res) ->
            dmn.dispose()
            cb err, res
        dmn.once 'error', (err) ->
          dmn.dispose()
          cb err
      else throw new Error "Unknown manner #{manner}"
  t

describe 'streams', ->
  _(['sync-cb', 'async-cb', 'sync-cb-throw', 'async-cb-throw']).each (lib_type) ->
    it "can use #{lib_type} libraries", (done) ->
      stream = best_practice_stream_factory lib_type
      stream.on 'error', (err) ->
        assert err.from_bad_lib, "expected to catch library error, caught something else: #{err}"
        done()
      input = _s.range 5
      input.pipe stream

# We also live in a world where libraries create streams with varying error states:
# 'emit': always emit errors
# 'throw': sometimes throw errors instead of emitting
# The only way to catch an error thrown by a stream is to run it within a domain. Since (a) there
# can only be one active domain and (b) you can have many streams running at a time, error handling
# is intractable once you introduce streams that throw errors. Thus, these kind of streams should be
# considered bugs.
# Proper streams expose an "error" event. For streams you create (via understream or not), it is
# your responsibility to listen to the errors they emit. Node provides domains as a way to listen
# for errors on many streams. Understream provides `values()` to extract all the streams you create
# in a chain().
