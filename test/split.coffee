assert = require 'assert'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
async = require 'async'
Readable = require 'readable-stream'

# domain_emitter (0.8) vs domainEmitter (0.10)
domain_emitter = (domain_err) ->
  domain_err.domain_emitter or domain_err.domainEmitter

describe '_.split', ->
  it 'requires a sep argument', ->
    assert.throws () ->
      _().stream().split()
    , /requires separator/
    assert.throws () ->
      _().stream({}).split()
    , /requires separator/
    assert.throws () ->
      _().stream({asdf:'asdf'}).split()
    , /requires separator/

  it 'must be piped string or buffer data', (done) ->
    test_inputs = [
      [1,2,3]
      [{a:'1'}, {b:'2'}, {c: '3'}]
    ]
    async.forEachSeries test_inputs, (test_input, cb_fe) ->
      _(test_input).stream().split("test").run (err) ->
        assert domain_emitter(err)?.options.sep is 'test'
        assert err.message.match /non-string\/buffer chunk/
        cb_fe()
    , done

  [
    { type: 'string', arg: '\n' }
    { type: 'regex', arg: /\n/ }
    { type: 'obj', arg: { sep: '\n' } }
  ].forEach (arg_spec) ->
    it "splits with a #{arg_spec.type} argument", (done) ->
      r = new Readable
      r.push "1\n2\n3\n"
      r.push null
      r._read = () ->
      _(r).stream().split(arg_spec.arg).run (err, val) ->
        assert.ifError err
        assert.deepEqual _(val).map(String), ['1','2','3']
        done()
