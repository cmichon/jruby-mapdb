lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
%w[rubygems tempfile jruby-mapdb].map &method(:require)
require 'test/unit'