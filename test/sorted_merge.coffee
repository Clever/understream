assert = require 'assert'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
inspect = require('util').inspect

# A (hopefully) correct implementation of the merge logic for sorted arrays
merge_oracle = (left, right, key) ->
  if _.isEmpty left
    _.map right, (r) -> [null, r]
  else if _.isEmpty right
    _.map left, (l) -> [l, null]
  else
    [l, r] = [_.first(left), _.first(right)]
    console.log l, r
    if l[key] is r[key]
      [[l, r]].concat merge_oracle _.rest(left), _.rest(right), key
    else if l[key] < r[key]
      [[l, null]].concat merge_oracle _.rest(left), right, key
    else if l[key] > r[key]
      [[null, r]].concat merge_oracle left, _.rest(right), key

describe '_.sorted_merge', ->

  lets = 'abcde'
  l = _.object lets, _.map lets, (x) -> key: x, val: 'l'
  r = _.object lets, _.map lets, (x) -> key: x, val: 'r'

  _.each [
    left: []
    right: []
    expected: []
  ,
    left: [ l.a ]
    right: []
    expected: [ [l.a, null] ]
  ,
    left: []
    right: [ r.a ]
    expected: [ [null, r.a] ]
  ,
    left: [ l.a ]
    right: [ r.a ]
    expected: [ [l.a, r.a] ]
  ,
    left: [ l.a ]
    right: [ r.b ]
    expected: [ [l.a, null], [null, r.b] ]
  ,
    left: [ l.b ]
    right: [ r.a ]
    expected: [ [null, r.a], [l.b, null] ]
  ,
    left: [ l.a, l.b ]
    right: [ r.a ]
    expected: [ [l.a, r.a], [l.b, null] ]
  ,
    left: [ l.a, l.c ]
    right: [ r.b ]
    expected: [ [l.a, null], [null, r.b], [l.c, null] ]
  ,
    left: [ l.a, l.c, l.d, l.e ]
    right: [ r.a ]
    expected: [ [l.a, r.a], [l.c, null], [l.d, null], [l.e, null] ]
  ,
    left: [ l.a, l.c, l.e ]
    right: [ r.a, r.d, r.e ]
    expected: [ [l.a, r.a], [l.c, null], [null, r.d], [l.e, r.e] ]
  ], ({left, right, expected}) ->

    it "oracle works for a small example:\n#{inspect left},\n#{inspect right}", ->
      actual = merge_oracle left, right, 'key'
      assert.deepEqual actual, expected

    it "works for a small example:\n#{inspect left},\n#{inspect right}", (done) ->
      _.sorted_merge(_.stream(left), _.stream(right), 'key')
        .value (actual) ->
          assert.deepEqual actual, expected
          done()
        .run assert.ifError
