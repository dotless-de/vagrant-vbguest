require 'optparse'
require 'vagrant/command/start_mixins'

module VagrantVbguest

  class Command < Vagrant::Command::Base
    include Vagrant::Command::StartMixins
    include VagrantVbguest::Helpers::Rebootable

    # Runs the vbguest installer on the VMs that are represented
    # by this environment.
    def execute
      options = {
        :_method => :run,
        :_rebootable => true,
        :auto_reboot => false
      }
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant vbguest [vm-name] [--do start|rebuild|install] [--status] [-f|--force] [-b|--auto-reboot] [-R|--no-remote] [--iso VBoxGuestAdditions.iso]"
        opts.separator ""

        opts.on("--do COMMAND", [:start, :rebuild, :install], "Manually `start`, `rebuild` or `install` GueastAdditions.") do |command|
          options[:_method] = command
          options[:force] = true
        end

        opts.on("--status", "Print current GuestAdditions status and exit.") do
          options[:_method] = :status
          options[:_rebootable] = false
        end

        opts.on("-f", "--force", "Whether to force the installation. (Implied by --do start|rebuild|install)") do
          options[:force] = true
        end

        opts.on("--auto-reboot", "-b", "Allow rebooting the VM after installation. (when GuestAdditions won't start)") do
          options[:auto_reboot] = true
        end

        opts.on("--no-remote", "-R", "Do not attempt do download the iso file from a webserver") do
          options[:no_remote] = true
        end

        opts.on("--iso file_or_uri", "Full path or URI to the VBoxGuestAdditions.iso") do |file_or_uri|
          options[:iso_path] = file_or_uri
        end

        build_start_options(opts, options)
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
      options     = options.clone
      _method     = options.delete(:_method)
      _rebootable = options.delete(:_rebootable)


      options = vm.config.vbguest.to_hash.merge(options)
      machine = VagrantVbguest::Machine.new(vm, options)
      status  = machine.state
      vm.ui.send (:ok == status ? :success : :warn), I18n.t("vagrant.plugins.vbguest.status.#{status}", machine.info)

      if _method != :status
        machine.send(_method)
      end

      reboot(vm, options) if _rebootable && machine.reboot?
    end

    def reboot vm, options
      if super
        vm.reload(options)
      end
    end
  end

end
