require 'vagrant'
require "vagrant-vbguest/config"
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

vbguest = Vagrant::Action::Builder.new do
  use VagrantVbguest::Middleware
end

Vagrant::Action.register(:vbguest, vbguest)
Vagrant.config_keys.register(:vbguest) { VagrantVbguest::Config }

[:start, :up, :reload].each do |level|
  Vagrant.actions[level].use VagrantVbguest::Middleware, :run_level => level
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
