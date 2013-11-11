{Readable} = require 'stream'

class ArrayStream extends Readable
  constructor: (@arr, @index=0) ->
    super objectMode: true
  _read: (size) =>
    @push @arr[@index++] # Note: push(undefined) signals the end of the stream, so this just works^tm

module.exports =
  fromArray: (arr) -> new ArrayStream arr
