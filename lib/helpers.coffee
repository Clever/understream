_ = require 'underscore'
{EventEmitter} = require 'events'

module.exports =
  is_readable: (instance) ->
    instance? and
    _.isObject(instance) and
    instance instanceof EventEmitter and
    instance.pipe? and
    (instance._read? or instance.read? or instance.readable)

  DEFAULT_MAX_LISTENERS: 10
