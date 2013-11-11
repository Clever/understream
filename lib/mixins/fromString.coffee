{Readable} = require 'stream'

class StringStream extends Readable
  constructor: (@str, @index=0) ->
    super objectMode: true
  _read: (size) =>
    @push @str[@index++] # Note: push(undefined) signals the end of the stream, so this just works^tm

module.exports =
  fromString: (str) -> new StringStream str
