module.exports =
  size: (readable, stream_opts={objectMode: readable._readableState.objectMode}) ->
    stream = @reduce readable,
      base: 0
      fn: (memo, chunk) ->
        memo += if readable._readableState.objectMode then 1 else chunk.length
    , stream_opts
    # readable side must be in objectMode since we're producing a non-string/buffer chunk
    stream._readableState.objectMode = true
    stream
