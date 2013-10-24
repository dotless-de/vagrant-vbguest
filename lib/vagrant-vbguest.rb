begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant VBGuest plugin must be run within Vagrant."
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

require 'vagrant-vbguest/errors'
require 'vagrant-vbguest/vagrant_compat'


module VagrantVbguest
  autoload :CommandCommons, 'vagrant-vbguest/command'
  autoload :Config,         'vagrant-vbguest/config'
  autoload :DownloadBase,   'vagrant-vbguest/download'
  autoload :Installer,      'vagrant-vbguest/installer'
  autoload :Machine,        'vagrant-vbguest/machine'
  autoload :Middleware,     'vagrant-vbguest/middleware'

  module Hosts
    autoload :Base,       'vagrant-vbguest/hosts/base'
    autoload :VirtualBox, 'vagrant-vbguest/hosts/virtual_box'
  end


  module Installers
    autoload :Base,   'vagrant-vbguest/installers/base'
    autoload :Linux,  'vagrant-vbguest/installers/linux'
    autoload :Debian, 'vagrant-vbguest/installers/debian'
    autoload :Redhat, 'vagrant-vbguest/installers/redhat'
    autoload :Ubuntu, 'vagrant-vbguest/installers/ubuntu'
  end


  class Plugin < Vagrant.plugin("2")

    name "vbguest management"
    description <<-DESC
    Provides automatic and/or manual management of the
    VirtualBox Guest Additions inside the Vagrant environment.
    DESC

    config('vbguest') do
      Config
    end

    command('vbguest') do
      Command
    end

    # hook after anything that boots:
    # that's all middlewares which will run the buildin "VM::Boot" action
    action_hook('vbguest') do |hook|
      if defined?(VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions)
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions, VagrantVbguest::Middleware)
      else
        hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, VagrantVbguest::Middleware)
      end
    end
  end
end
