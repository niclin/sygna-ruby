
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sygna/version"

Gem::Specification.new do |spec|
  spec.name          = "sygna"
  spec.version       = Sygna::VERSION
  spec.authors       = ["Nic"]
  spec.email         = ["niclin0226@gmail.com"]

  spec.summary       = "This is a Ruby library to help you build servers/services within Sygna Bridge Ecosystem."
  spec.description   = "This is a Ruby library to help you build servers/services within Sygna Bridge Ecosystem."
  spec.homepage      = "https://github.com/niclin/sygna"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/niclin/sygna"
    spec.metadata["changelog_uri"] = "https://github.com/niclin/sygna"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12"
  spec.add_development_dependency "rspec", "~> 3.7"
end
