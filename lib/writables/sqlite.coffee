{Writable} = require 'writable-stream-parallel'
_          = require 'underscore'
sqlite3    = require 'sqlite3'
debug      = require('debug') 'us:sqlite'
async      = require 'async'

mysql_real_escape_string = (str) ->
  str.replace /[\0\x08\x09\x1a\n\r"'\\\%]/g, (char) ->
    switch char
      when '\u0000' then '\\0'
      when '\b' then '\\b'
      when '\t' then '\\t'
      when '\u001a' then '\\z'
      when '\n' then '\\n'
      when '\r' then '\\r'
      when "'", '\\', '%'
        '\\' + char # prepends a backslash to backslash, percent,
      when '"' then '""'

# takes data and writes it to a sqlite table
# usage: .sqlite({ db: name, table: name })
class SQLite extends Writable
  constructor: (@options) ->
    super _(@options).extend objectMode: true
    debug options.db
    @db = new sqlite3.Database options.db
    @stats = {}
    @on 'finish', () =>
      @stmt.finalize()
      @db.run 'commit transaction', (err) =>
        @db.close()

  _write: (chunk, encoding, cb) =>
    async.waterfall [
      (cb_wf) =>
        return cb_wf() if @keys?
        @stats.start = new Date()
        @stats.inserts = 0
        @keys = _(chunk).keys()
        setup_cmds = []
        create_table = "create table \"#{mysql_real_escape_string @options.table}\" ("
        # todo detect types and make columns other than text
        create_table += _(@keys).map((k) -> "\"#{mysql_real_escape_string "" + k}\" text").join ','
        create_table += ')'
        setup_cmds.push create_table
        setup_cmds.concat [
          'pragma cache_size=-512000'
          'pragma synchronous=OFF'
          'pragma journal_mode=OFF'
          'pragma temp_store=MEMORY'
          'begin transaction'
        ]
        async.forEachSeries setup_cmds, (cmd, cb_fe) =>
          debug cmd
          @db.run cmd, cb_fe
        , cb_wf
      (cb_wf) =>
        @stmt ?= @db.prepare "insert into #{mysql_real_escape_string @options.table} values(" +
          _(@keys).map((k) -> '?').join(',') + ')'
        debug JSON.stringify (@keys).map((k) -> chunk[k])
        @stmt.run.apply(
          @stmt
          _(@keys).map((k) -> chunk[k]).concat cb_wf
        )
        # cmd = "insert into #{mysql_real_escape_string @options.table} values("
        # cmd += _(@keys).map((k) -> "\"#{mysql_real_escape_string "" + chunk[k]}\"").join ','
        # cmd += ')'
        # debug cmd
        # @db.run.apply @db, [cmd, cb_wf]
      (cb_wf) =>
        @stats.inserts += 1
        unless @stats.inserts % 1000
          elapsed = (new Date()) - @stats.start
          rate = @stats.inserts / (elapsed/1000)
          console.log "inserted #{@stats.inserts}. rate = #{rate}/s"
        cb_wf()
    ], cb

module.exports = (Understream) ->
  Understream.mixin SQLite, 'sqlite'
