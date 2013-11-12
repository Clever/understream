assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_s(a).chain()', ->
  it "has the methods of _s", ->
    assert _s().chain().each?
    assert _s('a').chain().each?

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
