{Readable, Writable, PassThrough} = require 'stream'
fs     = require('fs')
_      = require 'underscore'
domain = require 'domain'

class _s
  constructor: (obj) ->
    return obj if obj instanceof _s
    return new _s(obj) if not (@ instanceof _s)
    @_wrapped = obj

_([
  "fromArray"
  "fromString"
  "toArray"
  "each"
]).each (fn) -> _s[fn] = require("#{__dirname}/mixins/#{fn}")[fn]

# Adapted from underscore's mixin
# Add your own custom functions to the Understream object.
_s.mixin = (obj) ->
  _(obj).chain().functions().each (name) ->
    func = _s[name] = obj[name]
    _s.prototype[name] = ->
      args = [@_wrapped]
      Array::push.apply args, arguments
      res = result.call @, func.apply(_s, args)
      return res

# Add a "chain" function, which will delegate to the wrapper
_s.chain = (obj) -> _s(obj).chain()

# Helper function to continue chaining intermediate results
result = (obj) ->
  if @_chain then _s(obj).chain() else obj

# Add all of the Understream functions to the wrapper object
_s.mixin _s

_.extend _s.prototype,
  # start chaining a wrapped understream object
  chain: ->
    @_chain = true
    @
  # Extracts the result from a wrapped and chained object.
  value: -> @_wrapped

module.exports = _s
