require "jruby/mapdb/version"

module Jruby
  module Mapdb
    module ClassMethods
      include Enumerable
      def encode(key, value)
        @tree.put key, Marshal.dump(value).to_java_bytes
      end
      def decode(key)
        stored = @tree.get(key)
        return nil if stored.nil?
        Marshal.load String.from_java_bytes(stored)
      end
      def each
        @tree.each_pair { |key,value| yield(key, Marshal.load(String.from_java_bytes(value))) }
      end
      def key?(key)
        @tree.has_key? key
      end
      def keys
        @tree.key_set.to_a
      end
      def count
        @tree.size
      end
      def regexp(pattern)
        re = Regexp.new "#{pattern}", Regexp::EXTENDED | Regexp::IGNORECASE
        @tree.select{ |k,v| "#{k}" =~ re }.map(&:first)
      end
      alias :[]=  :encode
      alias :[]   :decode
      alias :size :count
      private
    end
    class Tree
      extend ClassMethods
    end
    class DB
      attr_reader :mapdb, :trees, :type
      def initialize(dbname=nil)
        if dbname.nil?
          @type = :MemoryDB
          @trees = []
          @mapdb = Java::OrgMapdb::DBMaker.
            newMemoryDB().
            closeOnJvmShutdown().
            make()
        else
          @type = :FileDB
          @trees = []
          @mapdb = Java::OrgMapdb::DBMaker.
            newFileDB(Java::JavaIo::File.new("#{dbname}")).
            closeOnJvmShutdown().
            writeAheadLogDisable().
            make()
        end
      end
      def tree(treename)
        raise "Tree already defined" if @trees.include?(treename) || Object.const_defined?(treename)
        trees << treename
        Object.const_set treename, Class.new(Tree)
        Object.const_get(treename).instance_variable_set :@mapdb, @mapdb
        Object.const_get(treename).instance_variable_set :@tree, @mapdb.getTreeMap("#{treename}")
      end
    end
  end
end
