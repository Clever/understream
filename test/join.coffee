assert = require 'assert'
async  = require 'async'
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
