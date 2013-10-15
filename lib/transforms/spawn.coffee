{spawn} = require 'child_process'
{Process} = require './process'

class Spawn
  constructor: (stream_opts, process_name, process_args) ->
    return new Process stream_opts, spawn(process_name, process_args)
module.exports = (Understream) ->
  Understream.mixin Spawn, 'spawn'
