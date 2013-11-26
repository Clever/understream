_ = require 'underscore'

module.exports = ->

  # The understream object can be used as an object with static methods:
  #     _s.each a, b
  # It can also be used as a function:
  #     _s(a).each b
  # In order to accommodate the latter case, all static methods also exist on _s.prototype
  # Thus, in the constructor we detect if called as a function and return a properly new'd
  # instance of _s containing all the prototype methods.
  class _s
    constructor: (obj, @prev_objs=[]) ->
      return new _s(obj, @prev_objs) if not (@ instanceof _s)
      @_wrapped = obj

    # Adapted from underscore's mixin
    # Add your own custom functions to the Understream object.
    @mixin: (obj) ->
      _(obj).chain().functions().each (name) ->
        func = _s[name] = obj[name]
        _s.prototype[name] = ->
          args = [@_wrapped]
          args.push arguments...
          # pop undefineds so that _s.fn() is equivalent to _s().fn()
          args.pop() while args.length and _(args).last() is undefined
          res = result.call @, func.apply(_s, args)
          res

    # Add a "chain" function, which will delegate to the wrapper
    @chain: (obj) -> _s(obj).chain()

    # Start accumulating results
    chain: ->
      @_chain = true
      @

    # Extracts the result from a wrapped and chained object.
    value: -> @_wrapped
    values: -> [@_wrapped].concat @prev_objs

  # Private helper function to continue chaining intermediate results
  result = (obj) ->
    if @_chain then _s(obj, @prev_objs.concat(@_wrapped)).chain() else obj

  _([
    "fromArray"
    "fromString"
    "toArray"
    "each"
    "map"
    "reduce"
    "filter"
    "where"
    "invoke"
    "groupBy"
    "first"
    "rest"
    "flatten"
    "uniq"
    "range"
  ]).each (fn) -> _s.mixin require("#{__dirname}/mixins/#{fn}")

  _s
