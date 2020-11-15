begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant VBGuest plugin must be run within Vagrant."
end

# Add our custom translations to the load path
I18n.load_path += Dir[File.expand_path("../../locales/*.yml", __FILE__)]
I18n.reload!

require "vagrant-vbguest/version"
require "vagrant-vbguest/errors"
require 'vagrant-vbguest/download'
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/machine'

require 'vagrant-vbguest/hosts/base'
require 'vagrant-vbguest/hosts/virtualbox'

require 'vagrant-vbguest/installer'
require 'vagrant-vbguest/installers/base'
require 'vagrant-vbguest/installers/linux'
require 'vagrant-vbguest/installers/debian'
require 'vagrant-vbguest/installers/ubuntu'
require 'vagrant-vbguest/installers/redhat'
require 'vagrant-vbguest/installers/centos'
require 'vagrant-vbguest/installers/oracle'
require 'vagrant-vbguest/installers/fedora'
require 'vagrant-vbguest/installers/opensuse'
require 'vagrant-vbguest/installers/suse'
require 'vagrant-vbguest/installers/archlinux'
require 'vagrant-vbguest/installers/windows'

module VagrantVbguest

  class Plugin < Vagrant.plugin("2")

    name "vagrant-vbguest"
    description <<-DESC
    Provides automatic and/or manual management of the
    VirtualBox Guest Additions inside the Vagrant environment.
    DESC

    config('vbguest') do
      require File.expand_path("../vagrant-vbguest/config", __FILE__)
      Config
    end

    command('vbguest') do
      Command
    end

    action_hook('vbguest', :machine_action_up) do |hook|
      require 'vagrant-vbguest/middleware'
      hook.append(VagrantVbguest::Middleware)
    end
  end
end
