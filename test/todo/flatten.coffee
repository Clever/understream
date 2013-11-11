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
tests = [
  {name: 'non-arrays', input: [1, 2]}
  {name: 'arrays', input: [[3], [4]]}
  {name: 'nested arrays', input: [[3], [[4]]]}
]
run_with_args = (args) ->
  _(tests).each (test) ->
    it "#{test.name} match underscore", (done) -> match_underscore 'flatten', test.input, args, done
describe '_.flatten', ->
  describe 'shallow', -> run_with_args [true]
  describe 'deep', -> run_with_args()
