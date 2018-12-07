require 'optparse'
require Vagrant.source_root.join("plugins/commands/up/start_mixins")
require 'vagrant-vbguest/helpers/rebootable'

module VagrantVbguest
  class Command < Vagrant.plugin("2", :command)
    include VagrantPlugins::CommandUp::StartMixins
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
        opts.banner = "Usage: vagrant vbguest [vm-name] "\
                      "[--do start|rebuild|install] "\
                      "[--status] "\
                      "[-f|--force] "\
                      "[-b|--auto-reboot] "\
                      "[-R|--no-remote] "\
                      "[--iso VBoxGuestAdditions.iso] "\
                      "[--no-cleanup]"

        opts.separator ""

        opts.on("--do COMMAND", [:start, :rebuild, :install], "Manually `start`, `rebuild` or `install` GuestAdditions.") do |command|
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

        opts.on("--no-cleanup", "Do not run cleanup tasks after installation. (for debugging)") do
          options[:no_cleanup] = true
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

    # Show description when `vagrant list-commands` is triggered
    def self.synopsis
      "plugin: vagrant-vbguest: install VirtualBox Guest Additions to the machine"
    end

    protected

    # Executes a task on a specific VM.
    #
    # @param vm [Vagrant::VM]
    # @param options [Hash] Parsed options from the command line
    def execute_on_vm(vm, options)
      check_runable_on(vm)

      options     = options.clone
      _method     = options.delete(:_method)
      _rebootable = options.delete(:_rebootable)

      options = vm.config.vbguest.to_hash.merge(options)
      machine = VagrantVbguest::Machine.new(vm, options)
      status  = machine.state
      vm.env.ui.send((:ok == status ? :success : :warn), I18n.t("vagrant_vbguest.status.#{status}", machine.info))

      if _method != :status
        machine.send(_method)
      end

      reboot!(vm, options) if _rebootable && machine.reboot?
    rescue VagrantVbguest::Installer::NoInstallerFoundError => e
      vm.env.ui.error e.message
    end

    def check_runable_on(vm)
      raise Vagrant::Errors::VMNotCreatedError if vm.state.id == :not_created
      raise Vagrant::Errors::VMInaccessible if vm.state.id == :inaccessible
      raise Vagrant::Errors::VMNotRunningError if vm.state.id != :running
      raise VagrantVbguest::NoVirtualBoxMachineError if vm.provider.class != VagrantPlugins::ProviderVirtualBox::Provider
    end
  end
end
