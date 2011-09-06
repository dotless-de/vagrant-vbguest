require 'vagrant'
require "vagrant-vbguest/config"
require 'vagrant-vbguest/command'
require 'vagrant-vbguest/middleware'

vbguest = Vagrant::Action::Builder.new do
  use VagrantVbguest::Middleware
end

Vagrant::Action.register(:vbguest, vbguest)

