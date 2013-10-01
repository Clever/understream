assert = require 'assert'
async  = require 'async'
inspect = require('util').inspect
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.join', ->
  it 'select * inner join on A.key=B.key', (done) ->
    A = _([{d: 0, e: 2, a: 0}, {d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{a:1, b:11, c: 22}, {a:2, b: 22, c: 44}, { a:3, b: 33, c: 66 }]).stream().stream()
    A.join({ from: B, on: 'a' }).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'select * inner join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    A.join({ from: B.stream(), on: {'a':'z'}}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, z: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, z: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, z: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, z: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'select A.*, B.b join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: 'b'}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11}
        {d: 2, e: 3, a: 1, b: 11}
        {d: 3, e: 4, a: 2, b: 22}
        {d: 4, e: 5, a: 2, b: 22}
      ]
      done()
    .run assert.ifError

  it 'select A.*, B.b, B.c join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: ['b','c']}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'select A.*, B.b as b_, B.c join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: [{'b':'b_'},'c']}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c: 22}
        {d: 2, e: 3, a: 1, b_: 11, c: 22}
        {d: 3, e: 4, a: 2, b_: 22, c: 44}
        {d: 4, e: 5, a: 2, b_: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'select A.*, B.b as b_, B.c as c_ left join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: ''}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ type: 'left', from: B, on: {'a': 'z'}, select: {'b': 'b_','c': 'c_'}}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
        {d: 4, e: 5, a: ''}
      ]
      done()
    .run assert.ifError

  it 'select A.*, B.b as b_, B.c as c_ join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: ''}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: {'b': 'b_','c': 'c_'}}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
      ]
      done()
    .run assert.ifError

describe '_.join again', ->

  KEY = 'key'       # key to join on in all the following tests
  MAX_LENGTH = 100  # size cap for randomly generated data
  NUM_TESTS = 10    # how many random tests to run

  lets = 'abcde'
  l = _.object lets, _.map lets, (x) -> _.object [[KEY, x], ['l', 'l']]
  r = _.object lets, _.map lets, (x) -> _.object [[KEY, x], ['r', 'r']]

  tests = [
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
  ]

  select_tests = [
    left: [ l.a, l.c, l.e ]
    right: [ r.a, r.d, r.e ]
    expected: [ [l.a, r.a], [l.c, null], [null, r.d], [l.e, r.e] ]
    select: 'r'
  ]

  # Helpers

  run_join = (options, left, right, done) ->
    _.stream(left).join(
      _.extend(
        from: _.stream(right).stream()
        on: KEY
      , options)
    ).value(done)
    .run assert.ifError

  # A (hopefully) correct implementation of the merge logic for sorted arrays
  merge_oracle = (left, right, key) ->
    if _.isEmpty left
      _.map right, (r) -> [null, r]
    else if _.isEmpty right
      _.map left, (l) -> [l, null]
    else
      [l, r] = [_.first(left), _.first(right)]
      if l[key] is r[key]
        [[l, r]].concat merge_oracle _.rest(left), _.rest(right), key
      else if l[key] < r[key]
        [[l, null]].concat merge_oracle _.rest(left), right, key
      else if l[key] > r[key]
        [[null, r]].concat merge_oracle left, _.rest(right), key

  describe 'merge oracle', ->
    _.each tests, ({left, right, expected}) ->
      it "works for a small example:\n#{inspect left},\n#{inspect right}", ->
        actual = merge_oracle left, right, KEY
        assert.deepEqual actual, expected

  combine_pairs = (pairs) -> _.map pairs, ([l, r]) -> _.extend {}, l, r
  filter_for_type = (type, pairs) ->
    switch type
      when 'outer' then pairs
      when 'inner' then _.filter pairs, ([l, r]) -> l? and r?
      when 'left' then _.filter pairs, ([l, r]) -> l?
      when 'right' then _.filter pairs, ([l, r]) -> r?
  prep = (expected, type) -> combine_pairs filter_for_type type, expected

  sort = (objs) -> _.sortBy objs, KEY

  run_join_tests = (options={}) ->

    # Run the handwritten tests
    _.each tests, ({left, right, expected}) ->
      it "works for a small example:\n#{inspect left},\n#{inspect right}", (done) ->
        console.log 'joining', left, right
        run_join options, _.values(left), _.values(right), (actual) ->
          assert.deepEqual sort(actual), prep(expected, options.type)
          done()

    _.each select_tests, ({left, right, expected, select}) ->
      it "works with select: #{inspect select}", (done) ->
        console.log 'joining', left, right, select, options.type
        opts = _.extend {}, options, select: select
        run_join opts, _.values(left), _.values(right), (actual) ->
          assert.deepEqual sort(actual), prep(expected, options.type)
          done()

    # Generate some random input data
    random_source = (side) ->
      source = _.chain([1..MAX_LENGTH])
        .map((i) -> _.object [[KEY, i], [side, i]])
        .sample(_.random MAX_LENGTH)
        .value()
      if options.sorted then sort source else source

    # Run _.join on the random data, using the oracle to get the expected results
    _.each [1..NUM_TESTS], (i) ->
      [left, right] = [random_source('left'), random_source('right')]
      it "works for random example #{i}:\n#{inspect left},\n#{inspect right}", (done) ->
        run_join options, left, right, (actual) ->
          expected = merge_oracle sort(left), sort(right), KEY
          assert.deepEqual sort(actual), prep(expected, options.type)
          done()

  describe 'hash join', ->
    _([
      #'outer' # not implemented
      'inner'
      'left'
      #'right' # implemented wrong
    ]).each (type) -> run_join_tests type: type

  describe 'sorted merge join', ->
    _([
      'outer'
      'inner'
      'left'
      'right'
    ]).each (type) -> run_join_tests sorted: true, type: type
