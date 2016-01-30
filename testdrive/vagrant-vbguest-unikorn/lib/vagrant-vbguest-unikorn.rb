begin
  require "vagrant-vbguest"
rescue LoadError
  raise "This Vagrant plugin requires the vagrant-vbguest plugin."
end

require "vagrant-vbguest-unikorn/version"
require "vagrant-vbguest-unikorn/installer"

module VagrantVbguestUnikorn
  class Plugin < Vagrant.plugin("2")

    name "vagrant-vbguest-unikorn"
    description "Extends vagrant-vbguest with an specific installer class " \
                "for a hypothetical specific linux called Unikorn."
  end
end
