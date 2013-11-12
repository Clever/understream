assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'
_ = require 'underscore'

# Takes an array and returns an array of adjacent pairs of elements in the
# array, wrapping around at the end.
adjacent = (arr) ->
  _.zip arr, _.rest(arr).concat [_.first arr]

methods = (obj) ->
  _.chain().functions(obj).without('value', 'mixin').value()

idSpy = -> sinon.spy (x) -> x

testEquivalent = (exp1, exp2) ->
  [spy1, spy2] = [idSpy(), idSpy()]
  _s.mixin fn: spy1
  v1 = exp1()
  _s.mixin fn: spy2 # Relies on _s.mixin overwriting fn
  v2 = exp2()
  it 'return the same result', -> assert.deepEqual v1, v2
  it 'have the same methods available on the result', -> assert.deepEqual methods(v1), methods(v2)
  it 'call the method the same number of times', -> assert.equal spy1.callCount, spy2.callCount
  it 'call the method with the same args', -> assert.deepEqual spy1.args, spy2.args

_.each
  'no-op':
    'plain'             : -> 'a'
    'unwrapped chained' : -> _s.chain('a').value()
    'wrapped chained'   : -> _s('a').chain().value()
  'no-arg':
    'unwrapped'         : -> _s.fn()
    'wrapped'           : -> _s().fn()
    'unwrapped chained' : -> _s.chain().fn().value()
    'wrapped chained'   : -> _s().chain().fn().value()
  'one-arg':
    'unwrapped'         : -> _s.fn('a')
    'wrapped'           : -> _s('a').fn()
    'unwrapped chained' : -> _s.chain('a').fn().value()
    'wrapped chained'   : -> _s('a').chain().fn().value()
  'multi-arg':
    'unwrapped'         : -> _s.fn('a', {b:1}, 2)
    'wrapped'           : -> _s('a').fn({b:1}, 2)
    'unwrapped chained' : -> _s.chain('a').fn({b:1}, 2).value()
    'wrapped chained'   : -> _s('a').chain().fn({b:1}, 2).value()
  'multiple functions':
    'unwrapped'         : -> _s.fn _s.fn('a', 'b'), 'c'
    'wrapped'           : -> _s(_s('a').fn('b')).fn('c')
    'unwrapped chained' : -> _s.chain('a').fn('b').fn('c').value()
    'wrapped chained'   : -> _s('a').chain().fn('b').fn('c').value()

, (exps, desc) ->
  describe desc, ->
    # Since equivalence is transitive, to assert that a group of expressions
    # are equivalent, we can assert that each one is equivalent to one other
    # one.
    _.each adjacent(_.pairs(exps)), ([[name1, exp1], [name2, exp2]]) ->
      describe "#{name1}/#{name2}", -> testEquivalent exp1, exp2
