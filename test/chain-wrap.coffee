assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'
_ = require 'underscore'

describe 'methods on wrapped/chained objects are the same as methods on _s', ->
  for obj in [_s(), _s('a'), _s().chain(), _s('a').chain(), _s().chain().chain()]
    assert.deepEqual(
      _.chain().functions(obj).without('value').value()
      _.chain().functions(_s).without('mixin').value()
    )

describe '_s(a)', ->
  it 'binds a as the first argument to the next method invoked', ->
    spy = sinon.spy ->
    _s.mixin fn: spy
    _s().fn(10)
    _s().fn(10, 20)
    _s('a').fn(10)
    _s('a').fn(10, 20)
    _s('a', 'b').fn(10)
    _s('a', 'b').fn(10, 20)
    assert.equal spy.callCount, 6
    assert.deepEqual spy.args, [
      [undefined, 10]
      [undefined, 10, 20]
      ['a', 10]
      ['a', 10, 20]
      ['a', 10]      # ignores > 1 argument
      ['a', 10, 20]  # ignores > 1 argument
    ]

  it '.fn(b) is equivalent to calling _s.fn(a,b)', ->
    spy = sinon.spy ->
    _s.mixin fn: spy
    _s.fn 'a', 'b'
    _s('a').fn('b')
    assert.equal spy.callCount, 2
    assert.deepEqual spy.args[0], ['a', 'b']
    assert.deepEqual spy.args[0], spy.args[1]

  it '.missing() throws', ->
    assert.throws () ->
      _s('a').missing()

describe '_s(a).chain()', ->
  it '.value() returns a', ->
    assert.equal _s().chain().value(), undefined
    assert.equal _s('a').chain().value(), 'a'

  it '.fn1(b).fn2(c).value() is equivalent to calling _s.fn2(_s.fn1(a, b), c)', ->
    spy1 = sinon.spy -> 1
    spy2 = sinon.spy -> 2
    _s.mixin {fn1: spy1, fn2: spy2}
    val = _s('a').chain().fn1('b').fn2('c').value()
    assert.equal val, 2
    assert.equal val, _s.fn2(_s.fn1('a', 'b'), 'c')
    assert.equal spy1.callCount, 2
    assert.equal spy2.callCount, 2
    assert.deepEqual spy1.args[0], ['a', 'b']
    assert.deepEqual spy1.args[1], ['a', 'b']
    assert.deepEqual spy2.args[0], [1, 'c']
    assert.deepEqual spy2.args[1], [1, 'c']
