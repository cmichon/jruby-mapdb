require "test_helper"

module MyTest
  def runner(type)
    db = @db
    assert_instance_of Jruby::Mapdb::DB, db
    assert_equal type, db.type

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
  end
end

class MemoryDBTest < Test::Unit::TestCase
  include MyTest
 
  def test_memory_db
    @db = Jruby::Mapdb::DB.new
    runner(:MemoryDB)
  end
end

class FileDBTest < Test::Unit::TestCase
  include MyTest
  def setup
    @f = Tempfile.new('testdb')
  end
  def teardown
    File.delete(@f.path + '.p')
    @f.unlink   
  end 
  def test_file_db
    @db = Jruby::Mapdb::DB.new(@f.path)
    runner(:FileDB)
  end
end