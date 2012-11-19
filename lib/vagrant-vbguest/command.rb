require 'optparse'

module VagrantVbguest

  class Command < Vagrant::Command::Base

    # Runs the vbguest installer on the VMs that are represented
    # by this environment.
    def execute
      options = {
        :auto_reboot => false
      }
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant vbguest [vm-name] [-f|--force] [--auto-reboot] [-I|--no-install] [-R|--no-remote] [--iso VBoxGuestAdditions.iso]"
        opts.separator ""

        opts.on("-f", "--force", "Whether to force the installation") do
          options[:force] = true
        end

        opts.on("--auto-reboot", "Reboot VM after installation") do
          options[:auto_reboot] = true
        end

        opts.on("--no-install", "-I", "Only check for the installed version. Do not attempt to install anything") do
          options[:no_install] = true
        end

        opts.on("--no-remote", "-R", "Do not attempt do download the iso file from a webserver") do
          options[:no_remote] = true
        end

        opts.on("--iso file_or_uri", "Full path or URI to the VBoxGuestAdditions.iso") do |file_or_uri|
          options[:iso_path] = file_or_uri
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
      options = vm.config.vbguest.to_hash.merge(options)
      VagrantVbguest::Installer.new(vm, options).run!
    end
  end
end
