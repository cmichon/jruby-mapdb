require "jruby/mapdb/version"
require "forwardable"

module Jruby
  module Mapdb
    module ClassMethods
      include Enumerable
      
      extend Forwardable
      def_delegator :@tree, :count, :size
      def_delegator :@tree, :has_key?, :key?

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
      def keys
        @tree.key_set.to_a
      end
      def regexp(pattern)
        re = Regexp.new "#{pattern}", Regexp::EXTENDED | Regexp::IGNORECASE
        @tree.select{ |k,v| "#{k}" =~ re }.map(&:first)
      end
      def clear
        @tree.clear
      end
      alias :[]=  :encode
      alias :[]   :decode
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
        raise "Tree '#{treename}' already defined" if @trees.include?(treename) || Object.const_defined?(treename)
        trees << treename
        mapdb = @mapdb
        Object.const_set treename, Class.new(Tree)
        Object.const_get(treename).instance_eval do  
          @mapdb, @tree = mapdb, mapdb.getTreeMap("#{treename}")
        end
        Object.const_get treename
      end
    end
  end
end
