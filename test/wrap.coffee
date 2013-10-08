assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.stream', ->

  it 'wraps an object implementing the Readable stream interface', (done) ->
    {Readable} = require 'stream'
    input = ['a', 'b', 'c']
    rs = new Readable objectMode: true
    rs.push item for item in input
    rs.push null
    _(rs).stream().value (result) ->
      assert.deepEqual input, result
      done()
    .run assert.ifError

  it 'wraps a mongoose stream', (done) ->
    mongoose = require 'mongoose'
    mongoose.connect 'localhost/test-understream'
    Doc = mongoose.model "Doc", new mongoose.Schema { foo: String }
    input = ['a', 'b', 'c']
    async.waterfall [
      (cb_wf) -> Doc.remove (err, dontcare) -> cb_wf err
      (cb_wf) ->
        async.forEach input, (str, cb_fe) ->
          new Doc({foo: str}).save cb_fe
        , (err, dontcare) ->
          cb_wf err
      (cb_wf) ->
        cnt = 0
        _(Doc.find().stream()).stream().each (doc) ->
          cnt++
          assert doc.foo in input
        .run (err) ->
          assert.ifError err
          assert.equal cnt, 3
          cb_wf()
    ], done
