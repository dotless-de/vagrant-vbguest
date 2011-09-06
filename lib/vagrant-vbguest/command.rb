module VagrantVbguest
  
  class Command < Vagrant::Command::Base
    register "vbguest", "Check and Update the VirtualBox Guest Additions"

    # Executes the given rake command on the VMs that are represented
    # by this environment.
    def execute
      target_vms.each { |vm| execute_on_vm(vm) }
    end

    protected

    # Executes a command on a specific VM.
    def execute_on_vm(vm)
      vm.env.actions.run(:vbguest)
    end
  end
end