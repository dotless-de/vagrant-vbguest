module VagrantVbguest
  vagrant_version = Gem::Version.new(Vagrant::VERSION)
  supported_version = {
    "< 1.1.0"  => "1_0",
    "~> 1.1.0" => "1_1",
    "~> 1.2.0" => "1_2",
    "~> 1.3.0" => "1_3",
  }
  @compat_version = supported_version.find { |requirement, version|
    Gem::Requirement.new(requirement).satisfied_by?(vagrant_version)
  }[1]

  if !@compat_version
    # @TODO: yield warning
    @compat_version = supported_version.to_a.last[1]
  end

  autoload :Command,  "vagrant-vbguest/vagrant_compat/vagrant_#{@compat_version}/command"
  autoload :Download, "vagrant-vbguest/vagrant_compat/vagrant_#{@compat_version}/download"

  module Helpers
    autoload :VmCompatible, "vagrant-vbguest/vagrant_compat/vagrant_#{@compat_version}/vm_compatible"
    autoload :Rebootable,   "vagrant-vbguest/vagrant_compat/vagrant_#{@compat_version}/rebootable"
  end
end
