assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_s(a)', ->
  it 'has the methods of _s', ->
    assert _s().each?
    assert _s('a').each?

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
