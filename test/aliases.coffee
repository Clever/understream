assert       = require 'assert'
_            = require 'underscore'
_s           = require "#{__dirname}/../index"
test_helpers = require './helpers'

describe 'aliases', ->
  _([
    ['each', 'forEach']
    ['filter', 'select']
    ['first', 'head', 'take']
    ['map', 'collect']
    ['reduce', 'inject', 'foldl']
    ['rest', 'tail', 'drop']
    ['uniq', 'unique']
  ]).each (alias_set) ->
    _(test_helpers.adjacent alias_set).each ([fn1, fn2]) ->
      it "#{fn1} === #{fn2}", ->
        assert _s[fn1] is _s[fn2]
