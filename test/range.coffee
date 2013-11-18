assert = require 'assert'
_s     = require "#{__dirname}/../index"
_      = require 'underscore'

readable_equals_array = (readable, array, cb) ->
  _s.toArray readable, (err, arr) ->
    assert.ifError err
    assert.deepEqual arr, array
    cb()

tests =
  'size': [5]
  'size 0': [0]
  'start, stop': [0, 10]
  'start, stop zero': [0, 0]
  'start, stop, step': [0, 10, 2]
  'start, stop zero, step': [0, 0, 2]
  'start, negative stop, negative step': [0, -10, -2]
  'start, stop zero, negative step': [0, 0, -2]
  'negative size': [-10]
  'start > stop': [10, 0]

describe '_s.range', ->
  _(tests).each (args, test) ->
    it test, (done) ->
      readable_equals_array _s.range.apply(_s, args), _.range.apply(_, args), done
