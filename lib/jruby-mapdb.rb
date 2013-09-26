(%w[java] + Dir['**/*.jar'] + %w[jruby/mapdb]).map &method(:require)
