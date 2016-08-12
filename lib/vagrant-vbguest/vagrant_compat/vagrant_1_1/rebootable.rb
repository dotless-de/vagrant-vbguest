require 'vagrant-vbguest/rebootable'

module VagrantVbguest
  module Helpers

    module Rebootable
      def reboot(vm, options)
        if reboot? vm, options
          simple_reboot = Vagrant::Action::Builder.new.tap do |b|
            b.use Vagrant::Action::Builtin::Call, Vagrant::Action::Builtin::GracefulHalt, :poweroff, :running do |env2, b2|
              if !env2[:result]
                b2.use VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt
              end
            end
            b.use VagrantPlugins::ProviderVirtualBox::Action::Boot
            if defined?(Vagrant::Action::Builtin::WaitForCommunicator)
              b.use Vagrant::Action::Builtin::WaitForCommunicator, [:starting, :running]
            end
          end
          @env[:action_runner].run(simple_reboot, @env)
        end
      end

      # executes the whole reboot process
      def reboot!(vm, options)
        if reboot? vm, options
          vm.action(:reload, options)
        end
      end
    end

  end
end
