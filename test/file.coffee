assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
util = require 'util'

describe '_.file', ->
  it 'works', (done) ->
    _.stream().file("#{__dirname}/test.txt", { encoding: 'utf8' }).run (err, data) ->
      assert.ifError err
      assert.equal data.join(), 'asdf\nqwer\nzxcv\n'
      done()
