# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "vagrant-vbguest"
  s.version     = File.read('VERSION').chop
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Schulze"]
  s.email       = ["robert@dotless.de"]
  s.license     = 'MIT'
  s.homepage    = "https://github.com/dotless-de/vagrant-vbguest"
  s.summary     = %q{A Vagrant plugin to install the VirtualBoxAdditions into the guest VM}
  s.description = %q{A Vagrant plugin which automatically installs the host's VirtualBox Guest Additions on the guest system.}

  s.required_ruby_version = ">= 2.0"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "micromachine", ">= 2", "< 4"

  # those should be satisfied by vagrant
  s.add_dependency "i18n"
  s.add_dependency "log4r"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|testdrive|\.github)/}) }
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/dotless-de/vagrant-vbguest/issues",
    "changelog_uri" => "https://github.com/dotless-de/vagrant-vbguest/blob/main/CHANGELOG.md",
    "documentation_uri" => "http://rubydoc.info/gems/vagrant-vbguest",
    "source_code_uri" => "https://github.com/dotless-de/vagrant-vbguest"
  }
end
