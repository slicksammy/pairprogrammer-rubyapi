Gem::Specification.new do |spec|
  spec.name          = 'pairprogrammer'
  spec.version       = '0.1.0'
  spec.authors       = ['Your Name']
  spec.email         = ['your.email@example.com']
  spec.summary       = 'Ruby CLI for interacting with coding assistant API'
  spec.description   = 'A Ruby command line interface gem for integrating with the coding assistant API for various tasks'
  spec.homepage      = 'https://github.com/username/pairprogrammer'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = ['pear']
  spec.require_paths = ['lib']
  spec.add_dependency 'httparty'
  spec.add_dependency 'json'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  
end
