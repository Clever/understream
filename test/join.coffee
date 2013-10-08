assert = require 'assert'
async  = require 'async'
inspect = require('util').inspect
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()

describe '_.join', ->
  it 'select * inner join on A.key=B.key', (done) ->
    A = _([{d: 0, e: 2, a: 0}, {d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{a:1, b:11, c: 22}, {a:2, b: 22, c: 44}, { a:3, b: 33, c: 66 }]).stream().stream()
    A.join({ from: B, on: 'a' }).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()

  it 'select * inner join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    A.join({ from: B.stream(), on: {'a':'z'}}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, z: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, z: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, z: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, z: 2, b: 22, c: 44}
      ]
      done()

  it 'select A.*, B.b join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: 'b'}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11}
        {d: 2, e: 3, a: 1, b: 11}
        {d: 3, e: 4, a: 2, b: 22}
        {d: 4, e: 5, a: 2, b: 22}
      ]
      done()

  it 'select A.*, B.b, B.c join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: ['b','c']}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()

  it 'select A.*, B.b as b_, B.c join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: [{'b':'b_'},'c']}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c: 22}
        {d: 2, e: 3, a: 1, b_: 11, c: 22}
        {d: 3, e: 4, a: 2, b_: 22, c: 44}
        {d: 4, e: 5, a: 2, b_: 22, c: 44}
      ]
      done()

  it 'select A.*, B.b as b_, B.c as c_ left join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: ''}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ type: 'left', from: B, on: {'a': 'z'}, select: {'b': 'b_','c': 'c_'}}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
        {d: 4, e: 5, a: ''}
      ]
      done()

  it 'select A.*, B.b as b_, B.c as c_ join on A.a=B.z', (done) ->
    A = _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: ''}]).stream()
    B = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream().stream()
    A.join({ from: B, on: {'a': 'z'}, select: {'b': 'b_','c': 'c_'}}).run (err, data) ->
      assert.ifError err
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
      ]
      done()

  describe 'sorted merge', ->

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

    lets = 'abcde'
    l = _.object lets, _.map lets, (x) -> key: x, l: 'l'
    r = _.object lets, _.map lets, (x) -> key: x, r: 'r'

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

    run_join = (left, right, done) ->
      _.stream(left).join
        from: _.stream(right).stream()
        on: 'key'
        type: 'outer'
        sorted: true
      .run (err, data) ->
        assert.ifError err
        done data

    combine_pairs = (pairs) -> _.map pairs, ([l, r]) -> _.extend {}, l, r

    _.each tests, ({left, right, expected}) ->

      it "oracle works for a small example:\n#{inspect left},\n#{inspect right}", ->
        actual = merge_oracle left, right, 'key'
        assert.deepEqual actual, expected

      it "works for a small example:\n#{inspect left},\n#{inspect right}", (done) ->
        console.log 'joining', left, right
        run_join _.values(left), _.values(right), (actual) ->
          assert.deepEqual actual, combine_pairs expected
          done()

    MAX_LENGTH = 100
    NUM_TESTS = 10

    random_source = (base) ->
      _.chain([1..MAX_LENGTH])
        .map((i) -> _.extend key: i, base i)
        .sample(_.random MAX_LENGTH)
        #.sortBy('key')
        .value()

    _.each [1..NUM_TESTS], (i) ->
      left = random_source (i) -> l: i
      right = random_source (i) -> r: i
      it "works for random example #{i}:\n#{inspect left},\n#{inspect right}", (done) ->
        run_join left, right, (actual) ->
          expected = combine_pairs merge_oracle left, right, 'key'
          assert.deepEqual actual, expected
          done()
