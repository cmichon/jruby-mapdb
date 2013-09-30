%w[jruby/mapdb/version forwardable].map &method(:require)

module Jruby
  module Mapdb
    module ClassMethods
      include Enumerable
      extend Forwardable
      def_delegator :@tree, :has_key?, :key?
      def_delegator :@tree, :count, :size
      def_delegator :@tree, :clear, :clear
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
      alias :[]=  :encode
      alias :[]   :decode
      alias :count :size
    end
    class Tree
      extend ClassMethods
    end
    class DB
      attr_reader :mapdb, :type
      def initialize(dbname=nil)
        if dbname.nil?
          @type = :MemoryDB
          @mapdb = Java::OrgMapdb::DBMaker.
            newMemoryDB().
            closeOnJvmShutdown().
            make()
        else
          @type = :FileDB
          @mapdb = Java::OrgMapdb::DBMaker.
            newFileDB(Java::JavaIo::File.new("#{dbname}")).
            closeOnJvmShutdown().
            transactionDisable().
            make()
        end
      end
      def tree(treename)
        raise "Tree '#{treename}' already defined" if @mapdb.get_all.map(&:first).include?("#{treename}") || Object.const_defined?(treename)
        Object.const_set treename, Class.new(Tree)
        Object.const_get(treename).instance_variable_set :@mapdb, @mapdb
        Object.const_get(treename).instance_variable_set :@tree, @mapdb.getTreeMap("#{treename}")
        Object.const_get treename
      end
    end
  end
end
