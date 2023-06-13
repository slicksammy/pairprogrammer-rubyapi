Gem::Specification.new do |spec|
  spec.name          = 'pear-programmer'
  spec.version       = '0.1.7'
  spec.authors       = ['Sam Edelstein']
  spec.email         = ['your.email@example.com']
  spec.summary       = 'Ruby CLI for interacting with coding assistant API'
  spec.description   = 'A Ruby command line interface gem for integrating with the coding assistant API for various tasks'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = ['pear-on']
  spec.require_paths = ['lib']
  # TODO add versions to these dependencies
  spec.add_dependency 'open3'
  spec.add_dependency 'colorize'
  spec.add_dependency 'tty-spinner'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'diffy'
  spec.add_dependency 'tty-prompt'
end
