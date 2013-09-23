lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jruby/mapdb/version'

Gem::Specification.new do |spec|
  spec.name          = "jruby-mapdb"
  spec.version       = Jruby::Mapdb::VERSION
  spec.authors       = ["Christian MICHON"]
  spec.email         = ["christian.michon@gmail.com"]
  spec.description   = %q{MapDB wrapper for JRuby}
  spec.summary       = %q{MapDB wrapper}
  spec.homepage      = "http://github.com/cmichon/jruby-mapdb"
  spec.license       = "MIT"

  spec.files         = Dir['{**/*}']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
