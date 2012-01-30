require 'optparse'

module VagrantVbguest
  
  class Command < Vagrant::Command::Base
    
    # Executes the given rake command on the VMs that are represented
    # by this environment.
    def execute
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant vbguest [vm-name] [-f|--force]"
        opts.separator ""

        opts.on("-f", "--force", "Whether to force the installation") do |f|
          options[:force] = f
        end
      end

      argv = parse_options(opts)
      return if !argv

      if argv.empty?
        with_target_vms(nil) { |vm| execute_on_vm(vm, options) }
      else
        argv.each do |vm_name| 
          with_target_vms(vm_name) { |vm| execute_on_vm(vm, options) }
        end
      end
      
    end

    protected

    # Executes a command on a specific VM.
    def execute_on_vm(vm, options)
      options.merge!(vm.config.vbguest.to_hash)
      VagrantVbguest::Installer.new(vm, options).run!
    end
  end
end
