require 'optparse'

module VagrantVbguest
  
  class Command < Vagrant::Command::Base
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vagrant vbguest [vm-name] [-f|--force]"
      opts.separator ""

      opts.on("-f", "--force", "Whether to force the installation") do |f|
        options[:force] = f
      end
    end

    # Executes the given rake command on the VMs that are represented
    # by this environment.
    def execute
      target_vms.each { |vm| execute_on_vm(vm) }
    end

    protected

    # Executes a command on a specific VM.
    def execute_on_vm(vm)
      vm.env.actions.run(:vbguest, "vbguest.force.install" => options[:force])
    end
  end
end
