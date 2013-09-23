(%w[java] + Dir['**/*.jar']).each { |jar| require jar }

require 'jruby/mapdb'
