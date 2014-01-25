_      = require 'underscore'
assert = require 'assert'
Understream = require "#{__dirname}/../index"

describe '_.uniq', ->
  expected = [1...4]

  describe 'sorted input', ->
    sorted_input = (i for i in [1...4])
    sorted_input.unshift sorted_input[0]

    describe 'underscore-style arguments', ->
      it 'works without a hash function', (done) ->
        new Understream(sorted_input).uniq(true).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        new Understream(sorted_input).uniq(true, String).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'options object', ->
      it 'works without a hash function', (done) ->
        new Understream(sorted_input).uniq(sorted: true).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        new Understream(sorted_input).uniq({sorted: true, hash_fn: String}).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'unsorted input', ->
      unsorted_input = (i for i in [1...4])
      unsorted_input.push unsorted_input[0]

      describe 'no arguments', ->
        it 'works', (done) ->
          new Understream(unsorted_input).uniq().run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()

      describe 'underscore-style arguments', ->
        it 'works with a hash function', (done) ->
          new Understream(unsorted_input).uniq(String).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid results with sorted true', (done) ->
          new Understream(unsorted_input).uniq(true).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()

      describe 'options object', ->
        it 'works with a hash function', (done) ->
          new Understream(unsorted_input).uniq(hash_fn: String).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid result with sorted true', (done) ->
          new Understream(unsorted_input).uniq(sorted: true).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()
