_ = require 'underscore'

# The understream object can be used as an object with static methods:
#     _s.each a, b
# It can also be used as a function:
#     _s(a).each b
# In order to accomodate the latter case, all static methods also exist on _s.prototype
# Thus, in the constructor we detect if called as a function and return a properly new'd
# instance of _s containing all the prototype methods.
class _s
  constructor: (obj) ->
    return new _s(obj) if not (@ instanceof _s)
    @_wrapped = obj

  # Adapted from underscore's mixin
  # Add your own custom functions to the Understream object.
  @mixin: (obj) ->
    _(obj).chain().functions().each (name) ->
      func = _s[name] = obj[name]
      _s.prototype[name] = ->
        args = [@_wrapped]
        args.push arguments...
        res = result.call @, func.apply(_s, args)
        res

  # Add a "chain" function, which will delegate to the wrapper
  @chain: (obj) -> _s(obj).chain()

  # Extracts the result from a wrapped and chained object.
  value: -> @_wrapped


# Fill static methods on _s
_([
  "fromArray"
  "fromString"
  "toArray"
  "each"
]).each (fn) -> _s[fn] = require("#{__dirname}/mixins/#{fn}")[fn]

# Helper function to continue chaining intermediate results
result = (obj) ->
  if @_chain then _s(obj).chain() else obj

# Add all of the Understream functions to the wrapper object
_s.mixin _s

# _s.mixin just copied the static _s.chain to the prototype, which is incorrect
# Fill in the correct method now
_.extend _s.prototype,
  chain: ->
    @_chain = true
    @

module.exports = _s
