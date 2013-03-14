require 'vagrant-vbguest/core_ext/string/interpolate'

require 'vagrant'
require "vagrant-vbguest/errors"
require 'vagrant-vbguest/helpers'

require 'vagrant-vbguest/machine'

require 'vagrant-vbguest/installer'
require 'vagrant-vbguest/installers/base'
require 'vagrant-vbguest/installers/linux'
require 'vagrant-vbguest/installers/debian'
require 'vagrant-vbguest/installers/ubuntu'
require 'vagrant-vbguest/installers/redhat'

require 'vagrant-vbguest/config'
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

require 'vagrant-vbguest/download'

Vagrant.config_keys.register(:vbguest) { VagrantVbguest::Config }

Vagrant.commands.register(:vbguest) { VagrantVbguest::Command }

Vagrant.actions[:start].use VagrantVbguest::Middleware

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
