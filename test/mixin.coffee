assert = require 'assert'
async = require 'async'
_     = require 'underscore'
understream = require "#{__dirname}/../index"
_.mixin understream.exports()
sinon = require 'sinon'
Readable = require 'readable-stream'

describe 'custom mixins', ->
  it 'works', (done) ->
    myawt = require './myawt'
    understream.mixin myawt.MyAwesomeTransform, 'myawt'
    _([1,2,3]).stream().myawt({}).value((result) ->
      assert.deepEqual result, [11, 12, 13]
      done()
    ).run assert.ifError

describe 'use your favorite dominctarr streams', ->
  it 'works', (done) ->
    through = require 'through'
    understream.mixin through, 'through', true
    _([1,2,3]).stream().through((data) -> @push data+10).value((result) ->
      assert.deepEqual result, [11, 12, 13]
      done()
    ).run assert.ifError
