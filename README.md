[![Build Status](https://secure.travis-ci.org/Clever/understream.png)](http://travis-ci.org/Clever/understream)

# Understream

Understream is a stream platform to make constructing stream chains considerably easier.

Understream is intended to be used with underscore:
```javascript
_ = require('underscore');
understream = require('understream');
_.mixin(understream.exports());
```

Out of the box, it supports many underscore-like functions, but it also makes it very easy to mix in your own streams:

```javascript
HOW DO I MAKE A STREAM CLASS IN JAVASCRIPT???
class Math extends Transform
    constructor: (stream_opts) -> super stream_opts
    _transform: (num, enc, cb) -> cb null, num+10
understream.mixin(Math, 'add10')
_.stream([3, 4, 5, 6]).add10().each(console.log).run(function (err) {
    console.log("ERR:", err);
});
# 13
# 14
# 15
# 16
```

## Methods

### Run
### Duplex
### Readable
### Defaults
### Pipe

## Default mixins

### Batch (transform)
`.batch(size)`

Creates batches out of the objects in your stream. Takes in objects, outputs arrays of those objects.

```javascript
_.stream([3, 4, 5, 6]).batch(3).each(console.log).run()
# [3, 4, 5]
# [6]
```

### Each (transform)
`.each(iterator)`

Calls the iterator function on each object in your stream, and passes the same object through when your interator function is done. If the iterator function has one argument (`(element)`), it is assumed to be synchronous. If it has two arguments, it is assumed to be asynchronous (`(element, cb)`).

```javascript
_.stream([3, 4, 5, 6]).each(console.log).run()
# 3
# 4
# 5
# 6
```

### File (transform)
`.file(filepath)`

Streams the content out of a file.

```javascript
_.stream().file(path_to_file).split('\n').each(console.log).run()
# line1
# line2
# line3
# ...
```

### Filter
`.each(iterator)`

Calls the iterator for each object in your stream, passing through only the values that pass a truth test (iterator).

```javascript
_.stream([3, 4, 5, 6]).filter(function (n) { return n > 4 }).each(console.log).run()
# 5
# 6
```

### First
`.first([n])`

Passes through only the first `n` objects. If called with no arguments, assumes `n` is `1`.

Passes through only the first object in the stream. Passing `n` will pass through the first `n` objects.

```javascript
_.stream([3, 4, 5, 6]).first(2).each(console.log).run()
# 3
# 4
```

### GroupBy

### Invoke

### Join

### Map

### Process

### Progress

### Queue

### Reduce

### Spawn

### Split

### Uniq

### Where
