module.exports =
  node_major: -> Number process.version.match(/^v(\d+)\.(\d+)\.(\d+)$/)[2]
  node_minor: -> Number process.version.match(/^v(\d+)\.(\d+)\.(\d+)$/)[3]
