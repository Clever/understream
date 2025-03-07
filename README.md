![Build Status](https://drone.ops.clever.com/github.com/Clever/understream/status.svg?branch=master)

# Understream

underscore-like functionality for dealing with streams.

# Wishlist

- support child_process.fork()ing streams to utilize > 1 cpu and more memory

# Note (as of 3/7/25)

There are circle CI related issues but we don't think these are worth fixing. This repo almost certainly never going to be worked on again and given the large node version upgrade, 12->18 most likely more code/tests will break and need to be updated as well.

There are currently 3 places this repo is used as a dependency:
https://github.com/Clever/migrations

https://github.com/Clever/legacy-normalizer

https://github.com/Clever/unix-sort

Of these only legacy-normalizer is still in use at Clever in an ongoing way.

Even the worker that uses this, legacy-normalizer, isn’t ever going to be worked on again, outside of the rare oncall fix. The team that owns legacy-normalizer
also wants to upgrade to a modern language/deps which will get it off understream. As such we are just going leave understream in the current state and then graveyard it once we get off legacy-normalizer.
