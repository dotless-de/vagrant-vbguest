# This file is automatically loaded by Vagrant < 1.1
# to load any plugins. This file kicks off this plugin.
begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant VBGuest plugin must be run within Vagrant."
end

require 'vagrant-vbguest/core_ext/string/interpolate'

require "vagrant-vbguest/errors"
require 'vagrant-vbguest/vagrant_compat'

require 'vagrant-vbguest/machine'

require 'vagrant-vbguest/hosts/base'
require 'vagrant-vbguest/hosts/virtualbox'

require 'vagrant-vbguest/installer'
require 'vagrant-vbguest/installers/base'
require 'vagrant-vbguest/installers/linux'
require 'vagrant-vbguest/installers/debian'
require 'vagrant-vbguest/installers/ubuntu'
require 'vagrant-vbguest/installers/redhat'

require 'vagrant-vbguest/config'
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

Vagrant.config_keys.register(:vbguest) { VagrantVbguest::Config }

Vagrant.commands.register(:vbguest) { VagrantVbguest::Command }

Vagrant.actions[:start].use VagrantVbguest::Middleware

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

