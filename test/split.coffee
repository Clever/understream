assert = require 'assert'
_      = require 'underscore'
Understream = require "#{__dirname}/../index"
async = require 'async'
{Readable} = require 'stream'

describe '_.split', ->
  it 'requires a sep argument', ->
    assert.throws (-> new Understream().split()), /requires separator/
    assert.throws (-> new Understream().split({})), /requires separator/
    assert.throws (-> new Understream().split({asdf: 'asdf'})), /requires separator/

  it 'must be piped string or buffer data', (done) ->
    test_inputs = [
      [1,2,3]
      [{a:'1'}, {b:'2'}, {c: '3'}]
    ]
    async.forEachSeries test_inputs, (test_input, cb_fe) ->
      new Understream(test_input).split("test").run (err) ->
        assert err.message.match /argument must be one of type string or Buffer/
        cb_fe()
    , done

  [
    { type: 'string', arg: '\n' }
    { type: 'regex', arg: /\n/ }
    { type: 'obj', arg: { sep: '\n' } }
  ].forEach (arg_spec) ->
    it "splits with a #{arg_spec.type} argument", (done) ->
      r = new Readable()
      r.push "1\n2\n3"
      r.push null
      r._read = ->
      new Understream(r).split(arg_spec.arg).run (err, val) ->
        assert.ifError err
        assert.deepEqual _(val).map(String), ['1','2','3']
        done()
