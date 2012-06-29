# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vagrant-vbguest/version"

Gem::Specification.new do |s|
  s.name        = "vagrant-vbguest"
  s.version     = VagrantVbguest::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Schulze"]
  s.email       = ["robert@dotless.de"]
  s.license     = 'MIT'
  s.homepage    = "https://github.com/dotless-de/vagrant-vbguest"
  s.summary     = %q{A Vagrant plugin to install the VirtualBoxAdditions into the guest VM}
  s.description = %q{A Vagrant plugin which automatically installs the host's VirtualBox Guest Additions on the guest system.}

  s.required_rubygems_version = ">= 1.3.6"
  #s.rubyforge_project = "vagrant-vbguest"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
