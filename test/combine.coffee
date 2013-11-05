assert = require 'assert'
_ = require 'underscore'
{Readable, Writable, PassThrough} = require 'stream'
{inspect} = require 'util'

understream = require '../index'
{combine} = understream
_.mixin understream.exports()

stream_from_array = (arr, objectMode = true) ->
  rs = new Readable {objectMode}
  _.each arr, (elt) -> rs.push elt
  rs.push null
  rs

lazy_stream_from_array = (arr) ->
  rs = new Readable objectMode: true
  i = 0
  rs._read = ->
    setImmediate =>
      @push arr[i]
      i += 1
  rs

describe 'combine', ->

  expected_err = /Expected Readable streams/
  it 'only accepts Readable streams on the right', ->
    assert.throws (-> combine stream_from_array([]), new Writable()), expected_err
  it 'only accepts Readable streams on the left', ->
    assert.throws (-> combine new Writable(), stream_from_array([])), expected_err
  it 'accepts any Readable streams', ->
    assert.doesNotThrow (-> combine new PassThrough(), stream_from_array([]))

  _.each [
    [[]                 , []]
    [['a', 'bc', 'def'] , []]
    [[]                 , ['a', 'bc', 'def']]
    [[1, 2]             , [3, 4]]
    [[0, 'zero']        , [{ a: 'a' }, [], 'so heterogenous']]
  ], ([left, right]) ->
    _.each [
      stream_from_array
      lazy_stream_from_array
    ], (make_stream) ->
      it "combines #{inspect left} with #{inspect right}", (done) ->
        combined = combine make_stream(left), make_stream(right)
        _.stream(combined).run (err, output) ->
          assert.ifError err
          # Order doesn't matter
          assert.deepEqual output.sort(), left.concat(right).sort()
          done()

  it 'works with objectMode: false', (done) ->
    [left, right] = [['abc', 'def', 'gh'], ['123', '456', '78']]
    combined = combine stream_from_array(left, false), stream_from_array(right, false)
    _.stream(combined).run (err, output) ->
      assert.ifError err
      assert.equal _(output).invoke('toString').sort().join(''),
        left.concat(right).sort().join('')
      done()

  it 'uses objectMode if the left stream is in objectMode', ->
    combined = combine stream_from_array([], false), stream_from_array([])
    assert combined._readableState.objectMode
  it 'uses objectMode if the right stream is in objectMode', ->
    combined = combine stream_from_array([]), stream_from_array([], false)
    assert combined._readableState.objectMode
