require 'vagrant'
require "vagrant-vbguest/config"
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

vbguest = Vagrant::Action::Builder.new do
  use VagrantVbguest::Middleware
end

Vagrant::Action.register(:vbguest, vbguest)

[:start, :up, :reload].each do |level|
  Vagrant::Action[level].use VagrantVbguest::Middleware, :run_level => level
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
