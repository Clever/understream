assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
Understream = require "#{__dirname}/../index"
util = require 'util'

describe '_.file', ->
  it 'works', (done) ->
    new Understream().file("#{__dirname}/test.txt", { encoding: 'utf8' }).run (err, data) ->
      assert.ifError err
      assert.equal data.join(), 'asdf\nqwer\nzxcv\n'
      done()
