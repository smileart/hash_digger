lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_digger/version'

Gem::Specification.new do |spec|
  spec.name          = 'hash_digger'
  spec.version       = HashDigger::VERSION
  spec.authors       = ['Serge Bedzhyk']
  spec.email         = ['smileart21@gmail.com']

  spec.summary       = %q{Hash Digger (improved)}
  spec.description   = %q{A utilitarian lib to extract data from complex Hashes using String path with recursions}
  spec.homepage      = 'https://github.com/smileart/hash_digger'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/smileart/hash_digger'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'm', '~> 1.5'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4'
  spec.add_development_dependency 'minitest', '~> 5.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'tapp', '~> 1.5'

  spec.add_runtime_dependency 'activesupport', '~> 6.1'
  spec.add_runtime_dependency 'amazing_print', '~> 1.3'
  spec.add_runtime_dependency 'ruby-try', '~> 1.1'
end
