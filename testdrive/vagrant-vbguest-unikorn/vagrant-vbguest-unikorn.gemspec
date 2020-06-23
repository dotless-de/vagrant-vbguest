# coding: utf-8
require File.expand_path('../lib/vagrant-vbguest-unikorn/version', __FILE__)
Gem::Specification.new do |spec|
  spec.name          = "vagrant-vbguest-unikorn"
  spec.version       = VagrantVbguestUnikorn::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Robert Schulze"]
  spec.email         = ["robert@dotless.de"]

  spec.summary       = "Sample of creating an own vagrant-vbguest Installer as gem"
  spec.description   = "Extends vagrant-vbguest vagrant plugin with an specific installer class " \
                        "for the hypothetical Unikorn Linux."
  spec.homepage      = "https://github.com/dotless-de/vagrant-vbguest/tree/main/testdrive/vagrant-vbguest-unikorn"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
