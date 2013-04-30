assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
util = require 'util'

describe '_.file', ->
  it 'works', (done) ->
    _.stream().file("#{__dirname}/test.txt", { encoding: 'utf8' }).value (data) ->
      assert.equal data.join(), 'asdf\nqwer\nzxcv\n'
      done()
    .run assert.ifError
