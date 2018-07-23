lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libxml/io/version'

Gem::Specification.new do |spec|
  spec.name          = 'libxml-io'
  spec.version       = LibXML::IO::VERSION
  spec.authors       = ['Anton Kozhemyachenko']
  spec.email         = ['gmerzu@gmail.com']

  spec.homepage      = 'https://github.com/gmerzu/libxml-io_gem'
  spec.summary       = 'LibXML xmlRegisterInputCallbacks extenstion for Ruby.'
  spec.description   = <<-EOS
    Allow to register an I/O callback for handling parser input (xmlRegisterInputCallbacks).
    Primary designed to use with Nokogiri which doesn't support this feature.
  EOS

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'bin'
  spec.extensions = ['ext/libxml-io/extconf.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.8.6'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-compiler', '~> 1.0'
  spec.add_development_dependency 'minitest', '~> 5.11'

  spec.license = 'MIT'
end
