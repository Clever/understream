assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
understream = require "#{__dirname}/../../index"
_.mixin understream.exports()
fs     = require 'fs'
temp   = require 'temp'

require('../sqlite') understream

describe '_.sqlite', ->
  error_free = (err) ->

  it 'writes json to a table', (done) ->
    tmpfilename = temp.path { suffix: '.db' }
    _.stream([{a:1,b:2,c:3}]).sqlite({ db: tmpfilename, table: "temp"}).run (err) ->
      assert.ifError err
      fs.unlink tmpfilename, done
