assert = require 'assert'
async = require 'async'
_sMaker = require "../lib/understream"
sinon = require 'sinon'
_ = require 'underscore'
test_helpers = require './helpers'

methods = (obj) ->
  _.chain().functions(obj).without('value', 'mixin').value()

testEquivalent = (exp1, exp2) ->
  [[v1, spy1], [v2, spy2]] = _.map [exp1, exp2], (exp) ->
    spy = sinon.spy (x) -> x
    _s = _sMaker()
    _s.mixin fn: spy
    [exp(_s), spy]
  it 'return the same result', -> assert.deepEqual v1, v2
  it 'have the same methods available on the result', -> assert.deepEqual methods(v1), methods(v2)
  it 'call the method the same number of times', -> assert.equal spy1.callCount, spy2.callCount
  it 'call the method with the same args', -> assert.deepEqual spy1.args, spy2.args

_.each
  'no-op':
    'plain'             : (_s) -> 'a'
    'unwrapped chained' : (_s) -> _s.chain('a').value()
    'wrapped chained'   : (_s) -> _s('a').chain().value()
  'no-arg':
    'unwrapped'         : (_s) -> _s.fn()
    'wrapped'           : (_s) -> _s().fn()
    'unwrapped chained' : (_s) -> _s.chain().fn().value()
    'wrapped chained'   : (_s) -> _s().chain().fn().value()
  'one-arg':
    'unwrapped'         : (_s) -> _s.fn('a')
    'wrapped'           : (_s) -> _s('a').fn()
    'unwrapped chained' : (_s) -> _s.chain('a').fn().value()
    'wrapped chained'   : (_s) -> _s('a').chain().fn().value()
  'multi-arg':
    'unwrapped'         : (_s) -> _s.fn('a', {b:1}, 2)
    'wrapped'           : (_s) -> _s('a').fn({b:1}, 2)
    'unwrapped chained' : (_s) -> _s.chain('a').fn({b:1}, 2).value()
    'wrapped chained'   : (_s) -> _s('a').chain().fn({b:1}, 2).value()
  'multiple functions':
    'unwrapped'         : (_s) -> _s.fn _s.fn('a', 'b'), 'c'
    'wrapped'           : (_s) -> _s(_s('a').fn('b')).fn('c')
    'unwrapped chained' : (_s) -> _s.chain('a').fn('b').fn('c').value()
    'wrapped chained'   : (_s) -> _s('a').chain().fn('b').fn('c').value()

  'no-op values':
    'unwrapped chained' : (_s) -> _s.chain('a').values()
    'wrapped chained'   : (_s) -> _s('a').chain().values()
  'no-arg values':
    'unwrapped chained' : (_s) -> _s.chain().fn().values()
    'wrapped chained'   : (_s) -> _s().chain().fn().values()
  'one-arg values':
    'unwrapped chained' : (_s) -> _s.chain('a').fn().values()
    'wrapped chained'   : (_s) -> _s('a').chain().fn().values()
  'multi-arg values':
    'unwrapped chained' : (_s) -> _s.chain('a').fn({b:1}, 2).values()
    'wrapped chained'   : (_s) -> _s('a').chain().fn({b:1}, 2).values()
  'multiple functions values':
    'unwrapped chained' : (_s) -> _s.chain('a').fn('b').fn('c').values()
    'wrapped chained'   : (_s) -> _s('a').chain().fn('b').fn('c').values()

, (exps, desc) ->
  describe desc, ->
    # Since equivalence is transitive, to assert that a group of expressions
    # are equivalent, we can assert that each one is equivalent to one other
    # one.
    _.each test_helpers.adjacent(_.pairs(exps)), ([[name1, exp1], [name2, exp2]]) ->
      describe "#{name1}/#{name2}", -> testEquivalent exp1, exp2
