require Vagrant.source_root.join("plugins/commands/up/start_mixins")

module VagrantVbguest

  class Command < Vagrant.plugin("2", :command)
    include CommandCommons
    include VagrantPlugins::CommandUp::StartMixins

    def check_runable_on(vm)
      raise Vagrant::Errors::VMNotCreatedError if vm.state.id == :not_created
      raise Vagrant::Errors::VMInaccessible if vm.state.id == :inaccessible
      raise Vagrant::Errors::VMNotRunningError if vm.state.id != :running
      raise VagrantVbguest::NoVirtualBoxMachineError if vm.provider.class != VagrantPlugins::ProviderVirtualBox::Provider
    end
  end

end
