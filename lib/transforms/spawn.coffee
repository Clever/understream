{spawn} = require 'child_process'
{Process} = require './process'
module.exports = (Understream) ->
  Understream.mixin ((args...) -> new Process {}, spawn args...), 'spawn', true
