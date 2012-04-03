require 'vagrant'
require "vagrant-vbguest/errors"
require "vagrant-vbguest/config"
require "vagrant-vbguest/detector"
require "vagrant-vbguest/download"
require "vagrant-vbguest/installer"
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

Vagrant.config_keys.register(:vbguest) { VagrantVbguest::Config }

Vagrant.commands.register(:vbguest) { VagrantVbguest::Command }

Vagrant.actions[:start].use VagrantVbguest::Middleware

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
