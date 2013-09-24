require 'test/unit'

class TDD < Test::Unit::TestCase
  def default_test
    eval DATA.read
  end
end

__END__

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

%w[rubygems tempfile jruby-mapdb].map &method(:require)

f = Tempfile.new('testdb')

types = [ :MemoryDB, :FileDB ]

[ Jruby::Mapdb::DB.new,
  Jruby::Mapdb::DB.new(f.path)
].each_with_index do |db,i|
  assert_instance_of Jruby::Mapdb::DB, db
  assert_equal types[i], db.type

  db.tree :People
  assert People.is_a?(Enumerable)
  assert_equal Jruby::Mapdb::Tree, People.superclass
  assert_equal [:People], db.trees
  assert_equal [], People.entries

  People[0] = 'CM'
  People[1] = {
    :name => 'CM',
    :features => {
      :developer => true
    }
  }

  assert People.key?(0)
  assert People.key?(1)
  assert_equal [1], People.regexp('^1$')
  assert_equal 2, People.size
  assert_equal 2, People.count
  assert_equal [0,1], People.keys

  assert_instance_of String, People[0]
  assert_equal 'CM', People[0]

  assert_instance_of Hash, People[1]
  assert_equal 'CM', People[1][:name]
  assert_instance_of Hash, People[1][:features]
  assert People[1][:features][:developer]

  assert_raise RuntimeError do
    db.tree :People
  end
  Object.send(:remove_const, :People)

  mapdb = db.instance_variable_get(:@mapdb)
  mapdb.close
  assert mapdb.closed?

  if i == 1
    File.delete(f.path + '.p')
    f.unlink
  end
end
