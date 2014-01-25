_      = require 'underscore'
assert = require 'assert'
Understream = require "#{__dirname}/../index"

bufs_to_lines = -> new Understream().split('\n').map(String).filter((s) -> s.length > 0).duplex()
Understream.mixin bufs_to_lines, 'bufs_to_lines', true

describe '_.spawn', ->
  it 'grep works with arguments', (done) ->
    input = ("#{i.toString()}\n" for i in [0..11])
    new Understream(input).spawn('grep', ['1']).bufs_to_lines().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, ['1', '10', '11']
      done()

  it 'echo works with arguments', (done) ->
    new Understream().spawn('echo', ['12']).bufs_to_lines().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, ['12']
      done()
