_      = require 'underscore'
assert = require 'assert'
understream = require("#{__dirname}/../index")
_.mixin understream.exports()

bufs_to_lines = -> _.stream().split('\n').map(String).duplex()
understream.mixin bufs_to_lines, 'bufs_to_lines', true

describe '_.spawn', ->
  it 'grep works with arguments', (done) ->
    input = ("#{i.toString()}\n" for i in [0..11])
    _(input).stream().spawn('grep', ['1']).bufs_to_lines().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, ['1', '10', '11']
      done()

  it 'echo works with arguments', (done) ->
    _.stream().spawn('echo', ['12']).bufs_to_lines().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, ['12']
      done()
