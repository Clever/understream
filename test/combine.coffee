assert = require 'assert'
_ = require 'underscore'
{Readable, Writable, PassThrough} = require 'stream'
{inspect} = require 'util'

{combine} = require '../index'

stream_from_array = (arr) ->
  # TODO test objectMode: false
  rs = new Readable objectMode: true
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
        result = combine make_stream(left), make_stream(right)
        output = []
        result.on 'data', (chunk) -> output.push chunk
        result.on 'error', done
        result.on 'end', ->
          # Order doesn't matter
          assert.deepEqual output.sort(), left.concat(right).sort()
          done()

  expected_err = /Expected Readable streams/
  it 'only accepts Readable streams on the right', ->
    assert.throws (-> combine new Readable(), new Writable()), expected_err
  it 'only accepts Readable streams on the left', ->
    assert.throws (-> combine new Writable(), new Readable()), expected_err
  it 'accepts any Readable streams', ->
    assert.doesNotThrow (-> combine new PassThrough(), new Readable())
