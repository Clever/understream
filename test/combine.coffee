assert = require 'assert'
_ = require 'underscore'
{PassThrough, Readable, Writable} = require 'stream'
{inspect} = require 'util'

understream = require '../index'
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

  it 'throws an error unless all streams are readable', ->
    _.each [
      [stream_from_array([]), new Writable()]
      [new Writable(), stream_from_array([])]
      [new Writable(), stream_from_array([]), new Writable()]
      [stream_from_array([]), stream_from_array([]), new Writable()]
    ], (streams) ->
      assert.throws (-> _.stream().combine(streams)), /Expected Readable streams/
  it 'accepts any Readable streams', ->
    _.each [
      [new PassThrough(), stream_from_array([])]
      [new PassThrough(), stream_from_array([]), new PassThrough()]
      [new PassThrough(), stream_from_array([]), stream_from_array([])]
    ], (streams) ->
      assert.doesNotThrow (-> _.stream().combine(streams))

  _.each [
    []
    [['a', 'bc', 'def'] , []]
    [[]                 , ['a', 'bc', 'def']]
    [[]                 , []                                  , []]
    [['a', 'bc', 'def'] , []                                  , [1, 2 ,3]]
    [[]                 , ['a', 'bc', 'def']                  , [1, 2, 3]]
    [[1, 2]             , [3, 4]                              , [5, 6]          , [7, 8]]
    [[0, 'zero']        , [{ a: 'a' }, [], 'so heterogenous'] , [new Date(), 5]]
  ], (stream_data) ->
    _.each [
      {constructor: stream_from_array}
      {constructor: lazy_stream_from_array, name: 'lazy'}
    ], ({constructor, name}) ->
      it "#{if name then name + ' ' else ''}combines #{inspect stream_data}", (done) ->
        streams = _(stream_data).map (data) -> constructor data
        _.stream().combine(streams).run (err, output) ->
          assert.ifError err
          # Order doesn't matter
          assert.deepEqual output.sort(), _(stream_data).flatten(true).sort()
          done()

  it 'works with objectMode: false', (done) ->
    stream_data = [['abc', 'def', 'gh'], ['123', '456', '78'], [new Date().toString()]]
    streams = _(stream_data).map (stream) -> stream_from_array stream, false
    _.stream().combine(streams).run (err, output) ->
      assert.ifError err
      assert.equal _(output).invoke('toString').sort().join(''),
        _(stream_data).flatten(true).sort().join('')
      done()

  it 'uses objectMode if any stream is in objectMode', ->
    _.each [
      [stream_from_array([], false), stream_from_array([])]
      [stream_from_array([]), stream_from_array([], false)]
      [stream_from_array([]), stream_from_array([]), stream_from_array([], false)]
      [stream_from_array([]), stream_from_array([], false), stream_from_array([], false)]
    ], (streams) ->
      combined = _.stream().combine(streams).stream()
      assert combined._readableState.objectMode
