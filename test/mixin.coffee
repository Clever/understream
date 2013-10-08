assert = require 'assert'
async = require 'async'
_     = require 'underscore'
understream = require "#{__dirname}/../index"
_.mixin understream.exports()
{Readable} = require 'stream'

describe 'custom mixins', ->
  it 'works', (done) ->
    myawt = require './myawt'
    understream.mixin myawt.MyAwesomeTransform, 'myawt'
    _([1,2,3]).stream().myawt({}).value((result) ->
      assert.deepEqual result, [11, 12, 13]
      done()
    ).run assert.ifError

describe 'use your favorite dominctarr streams', ->
  it 'works with through', (done) ->
    through = require 'through'
    understream.mixin through, 'through', true
    _([1,2,3]).stream().through((data) -> @push data+10).value((result) ->
      assert.deepEqual result, [11, 12, 13]
      done()
    ).run assert.ifError

  it 'works with jsonstream', (done) ->
    jsonstream = require 'JSONStream'
    readable = new Readable()
    readable._read = () ->
    readable.push '{"a":"1","b":"2"}\n'
    readable.push '{"a":"3","b":"4"}\n'
    readable.push null
    understream.mixin jsonstream.parse, 'json', true
    _(readable).stream().json().value((result) ->
      assert.deepEqual result, [{a:"1", b:"2"},{a:"3", b:"4"}]
      done()
    ).run assert.ifError
