_      = require 'underscore'
assert = require 'assert'
_.mixin require("#{__dirname}/../index").exports()

describe '_.uniq', ->
  expected = [1...4]

  describe 'sorted input', ->
    sorted_input = (i for i in [1...4])
    sorted_input.unshift sorted_input[0]

    describe 'underscore-style arguments', ->
      it 'works without a hash function', (done) ->
        _(sorted_input).stream().uniq(true).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        _(sorted_input).stream().uniq(true, String).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'options object', ->
      it 'works without a hash function', (done) ->
        _(sorted_input).stream().uniq(sorted: true).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()
      it 'works with a hash function', (done) ->
        _(sorted_input).stream().uniq({sorted: true, hash_fn: String}).run (err, result) ->
          assert.ifError err
          assert.deepEqual result, expected
          done()

    describe 'unsorted input', ->
      unsorted_input = (i for i in [1...4])
      unsorted_input.push unsorted_input[0]

      describe 'no arguments', ->
        it 'works', (done) ->
          _(unsorted_input).stream().uniq().run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()

      describe 'underscore-style arguments', ->
        it 'works with a hash function', (done) ->
          _(unsorted_input).stream().uniq(String).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid results with sorted true', (done) ->
          _(unsorted_input).stream().uniq(true).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()

      describe 'options object', ->
        it 'works with a hash function', (done) ->
          _(unsorted_input).stream().uniq(hash_fn: String).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, expected
            done()
        it 'gives invalid result with sorted true', (done) ->
          _(unsorted_input).stream().uniq(sorted: true).run (err, result) ->
            assert.ifError err
            assert.deepEqual result, unsorted_input
            done()
