assert = require 'assert'
async = require 'async'
_     = require 'underscore'
Understream = require "#{__dirname}/../index"
{Readable} = require 'stream'

describe 'custom mixins', ->
  it 'works old-style', (done) ->
    myawt = require './myawt'
    Understream.mixin myawt.MyAwesomeTransform, 'myawt'
    new Understream([1,2,3]).myawt({}).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, [11, 12, 13]
      done()
  it 'supports underscore-like mixins', (done) ->
    myawt = require './myawt'
    Understream.mixin myawt: myawt.MyAwesomeTransform
    new Understream([1,2,3]).myawt({}).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, [11, 12, 13]
      done()

describe 'use your favorite dominctarr streams', ->
  it 'works with through', (done) ->
    through = require 'through'
    Understream.mixin through, 'through', true
    new Understream([1,2,3]).through((data) -> @push data+10).run (err, result) ->
      assert.ifError err
      assert.deepEqual result, [11, 12, 13]
      done()

  it 'works with jsonstream', (done) ->
    jsonstream = require 'JSONStream'
    readable = new Readable()
    readable._read = () ->
    readable.push '{"a":"1","b":"2"}\n'
    readable.push '{"a":"3","b":"4"}\n'
    readable.push null
    Understream.mixin jsonstream.parse, 'json', true
    new Understream(readable).json().run (err, result) ->
      assert.ifError err
      assert.deepEqual result, [{a:"1", b:"2"},{a:"3", b:"4"}]
      done()
