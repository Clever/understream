assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon  = require 'sinon'
stream = require 'stream'
util = require 'util'

describe '_.join', ->
  it 'joins two json streams', (done) ->
    join_ustream = _([{a:1, b:11, c: 22}, {a:2, b: 22, c: 44}]).stream().stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream, on: 'a' }).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams on potentially different keys', (done) ->
    join_ustream = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream.stream(), on: 'z', as: 'a' }).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, z: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, z: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, z: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, z: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams on potentially different keys, selecting a single field', (done) ->
    join_ustream = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream.stream(), on: 'z', as: 'a', select: 'b'}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11}
        {d: 2, e: 3, a: 1, b: 11}
        {d: 3, e: 4, a: 2, b: 22}
        {d: 4, e: 5, a: 2, b: 22}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams on potentially different keys, selecting a subset of fields', (done) ->
    join_ustream = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream.stream(), on: 'z', as: 'a', select: ['b','c']}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: 11, c: 22}
        {d: 2, e: 3, a: 1, b: 11, c: 22}
        {d: 3, e: 4, a: 2, b: 22, c: 44}
        {d: 4, e: 5, a: 2, b: 22, c: 44}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams on potentially different keys, selecting a subset of renamed fields', (done) ->
    join_ustream = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream.stream(), on: 'z', as: 'a', select: {'b': 'b_','c': 'c_'}}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
        {d: 4, e: 5, a: 2, b_: 22, c_: 44}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams on potentially different keys, selecting a subset of renamed fields, unsetting if no match', (done) ->
    # test default behavior
    join_ustream = _([{z:1, b:11, c: 22}, {z:2, b: 22, c: 44}]).stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: ''}]).stream()
    .join({ from: join_ustream.stream(), on: 'z', as: 'a', select: {'b': 'b_','c': 'c_'}, unset: true}).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b_: 11, c_: 22}
        {d: 2, e: 3, a: 1, b_: 11, c_: 22}
        {d: 3, e: 4, a: 2, b_: 22, c_: 44}
        {d: 4, e: 5}
      ]
      done()
    .run assert.ifError

  it 'joins two json streams, and handles multiple values and undefined values', (done) ->
    join_ustream = _([{d:1, b:11}, {d:1, b: 22}, {d:2, b: 33}]).stream().stream()
    _([{d: 1, e: 2, a: 1}, {d: 2, e: 3, a: 1}, {d: 3, e: 4, a: 2}, {d: 4, e: 5, a: 2}]).stream()
    .join({ from: join_ustream, on: 'd', select: 'b' }).value (data) ->
      assert.deepEqual data, [
        {d: 1, e: 2, a: 1, b: [11, 22]}
        {d: 2, e: 3, a: 1, b: 33}
        {d: 3, e: 4, a: 2}
        {d: 4, e: 5, a: 2}
      ]
      done()
    .run assert.ifError
