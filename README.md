# Jruby::Mapdb

This is a jruby-only wrapper for MapDB (v0.9.5). MapDB is a fast key-value store java library.

Using this gem, MapDB trees are seen as hashes in jruby, making persistence easy and cheap.

2 types of storage from MapDB are available through the API:
* MemoryDB
* FileDB

Both MapDB types can co-exist in a same application provided their trees' names do not clash in Class namespace. Exceptions will be raised in such cases.

## Installation

Add this line to your application's Gemfile:

    gem 'jruby-mapdb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jruby-mapdb

## Usage

* MemoryDB scenario:

~~~ ruby

require 'jruby-mapdb'

db = Jruby::Mapdb::DB.new # the MemoryDB MapDB

db.tree :People # this will derive a class 'People' from Jruby::Mapdb::Tree, usable as a Hash

People[0] = 'CM'
p People[0]

People[1] = { :name => 'CM', :features => { :developer => true } }
p People[1]

~~~

* FileDB scenario:

~~~ ruby

require 'jruby-mapdb'

db = Jruby::Mapdb::DB.new(:foodb) # the FileDB MapDB => 2 files created ('foodb' and 'foodb.p')

db.tree :People # this will derive a class 'People' from Jruby::Mapdb::Tree, usable as a Hash

People[0] = 'CM'
p People[0]

People[1] = { :name => 'CM', :features => { :developer => true } }
p People[1]

~~~

## Jruby::Mapdb::Tree API

This API has been kept as simple as possible, compatible with Ruby Hash.

It is compatible with most Enumerable methods: each, find_all, select, reject, entries, etc...

~~~

#[](key)                  retrieve the value stored in tree with key. If the key is not defined yet, return nil.

#[]=(key, value)          store value with key in tree: key *cannot* be nil.

#key?(key)                true if the key is defined in the tree, false otherwise.

#keys                     returns array of all keys stored in tree

#count                    returns count of all keys stored in tree
#size                     returns count of all keys stored in tree

#regexp(pattern)          returns array of matched keys with pattern (extended + ignorecase)

#clear                    empty tree (remove all previously stored keys and values)

~~~

## Testing

Testing is done using Test::Unit, and has been verified on jruby 1.6.8, 1.7.4, 1.7.5dev in both 1.8 and 1.9 modes.

~~~
$ rake
~~~

## Contributors

* fntzr (test refactoring)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
