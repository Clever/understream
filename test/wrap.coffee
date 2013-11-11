assert = require 'assert'
async = require 'async'
_s = require "#{__dirname}/../index"
sinon = require 'sinon'

describe '_s(a).fn(b)', ->
  it 'is equivalent to calling _s.fn(a,b)', ->
    spy = sinon.spy ->
    _s.mixin fn: spy
    _s.fn 'a', 'b'
    _s('a').fn('b')
    assert.equal spy.callCount, 2
    assert.deepEqual spy.args[0], ['a', 'b']
    assert.deepEqual spy.args[0], spy.args[1]
