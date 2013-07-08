assert = require 'assert'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
async = require 'async'

describe '_.split', ->
  it 'requires a sep argument', ->
    assert.throws () ->
      _('').stream().split()
    , /requires separator/
    assert.throws () ->
      _('').stream({}).split()
    , /requires separator/
    assert.throws () ->
      _('').stream({asdf:'asdf'}).split()
    , /requires separator/

  it 'must be piped string or buffer data', (done) ->
    test_inputs = [
      [1,2,3]
      [{a:'1'}, {b:'2'}, {c: '3'}]
    ]
    async.forEachSeries test_inputs, (test_input, cb_fe) ->
      _(test_input).stream().split("test").run (err) ->
        assert err.domain_emitter?.options.sep is 'test'
        assert err.message.match /non-string\/buffer chunk/
        cb_fe()
    , done
