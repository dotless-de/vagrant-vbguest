require 'vagrant-vbguest/rebootable'

module VagrantVbguest
  module Helpers

    module Rebootable
      def reboot(vm, options)
        if reboot? vm, options
          @env[:action_runner].run(Vagrant::Action::VM::Halt, @env)
          @env[:action_runner].run(Vagrant::Action::VM::Boot, @env)
        end
      end

      # executes the whole reboot process
      def reboot!(vm, options)
        if reboot? vm, options
          vm.reload(options)
        end
      end
    end

  end
end
