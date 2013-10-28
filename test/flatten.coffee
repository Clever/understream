assert = require 'assert'
async = require 'async'
_     = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

match_underscore = (fn, input, args, cb) ->
  [fn, input, args, cb] = [fn, input, [], args] if arguments.length is 3
  _(input).stream()[fn](args...).run (err, result) ->
    assert.ifError err
    assert.deepEqual result, _(input)[fn](args...)
    cb()

describe '_.flatten', ->
  describe 'shallow', ->
    it 'non-arrays flatten right', (done) ->
      match_underscore 'flatten', [1, 2], [true], done

    it 'arrays flatten right', (done) ->
      match_underscore 'flatten', [[3], [4]], [true], done

    it 'nested arrays flatten right', (done) ->
      match_underscore 'flatten', [[3], [[4]]], [true], done

  describe 'deep', ->
    it 'non-arrays flatten right', (done) ->
      match_underscore 'flatten', [1, 2], done

    it 'arrays flatten right', (done) ->
      match_underscore 'flatten', [[3], [4]], done

    it 'nested arrays flatten right', (done) ->
      match_underscore 'flatten', [[3], [[4]]], done
