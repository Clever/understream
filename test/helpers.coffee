_ = require 'underscore'

module.exports =
  node_major: -> Number process.version.match(/^v(\d+)\.(\d+)\.(\d+)$/)[2]
  node_minor: -> Number process.version.match(/^v(\d+)\.(\d+)\.(\d+)$/)[3]

  # Takes an array and returns an array of adjacent pairs of elements in the
  # array, wrapping around at the end.
  adjacent: (arr) ->
    _.zip arr, _.rest(arr).concat [_.first arr]
