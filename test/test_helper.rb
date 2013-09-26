$: << File.expand_path('../lib', __FILE__)
%w[rubygems test/unit tempfile jruby-mapdb].map &method(:require)
