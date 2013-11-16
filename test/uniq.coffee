_      = require 'underscore'
assert = require 'assert'
_s = require "#{__dirname}/../index"

describe '_.uniq', ->
  expected = [1...4]

  describe 'sorted input', ->
    sorted_input = (i for i in [1...4])
    sorted_input.unshift sorted_input[0]

    describe 'underscore-style arguments', ->
      it 'works without a hash function', (done) ->
        _s(_s.fromArray sorted_input).chain().uniq(true).toArray (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        _s(_s.fromArray sorted_input).chain().uniq(true, String).toArray (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'options object', ->
      it 'works without a hash function', (done) ->
        _s(_s.fromArray sorted_input).chain().uniq(sorted: true).toArray (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        _s(_s.fromArray sorted_input).chain().uniq({sorted: true, hash_fn: String}).toArray (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'unsorted input', ->
      unsorted_input = (i for i in [1...4])
      unsorted_input.push unsorted_input[0]

      describe 'no arguments', ->
        it 'works', (done) ->
          _s(_s.fromArray unsorted_input).chain().uniq().toArray (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()

      describe 'underscore-style arguments', ->
        it 'works with a hash function', (done) ->
          _s(_s.fromArray unsorted_input).chain().uniq(String).toArray (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid results with sorted true', (done) ->
          _s(_s.fromArray unsorted_input).chain().uniq(true).toArray (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()

      describe 'options object', ->
        it 'works with a hash function', (done) ->
          _s(_s.fromArray unsorted_input).chain().uniq(hash_fn: String).toArray (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid result with sorted true', (done) ->
          _s(_s.fromArray unsorted_input).chain().uniq(sorted: true).toArray (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()
