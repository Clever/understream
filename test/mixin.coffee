assert = require 'assert'
async = require 'async'
_     = require 'underscore'
understream = require "#{__dirname}/../index"
_.mixin understream.exports()
sinon = require 'sinon'
Readable = require 'readable-stream'

myawt = require './myawt'

understream.mixin myawt.MyAwesomeTransform, 'myawt'

describe 'custom mixins', ->
  it 'works', (done) ->
    _([1,2,3]).stream().myawt({}).value((result) ->
      assert.deepEqual result, [11, 12, 13]
      done()
    ).run assert.ifError
