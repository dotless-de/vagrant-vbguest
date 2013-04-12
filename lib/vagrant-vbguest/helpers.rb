module VagrantVbguest
  module Helpers

    module Rebootable
      @@rebooted = {}

      def rebooted?(vm)
        !!@@rebooted[ VmCompatible.vm_id(vm) ]
      end

      def reboot?(vm, options)
        if rebooted?(vm)
          vm.env.ui.error(I18n.t("vagrant.plugins.vbguest.restart_loop_guard_activated"))
          false
        elsif options[:auto_reboot]
          vm.env.ui.warn(I18n.t("vagrant.plugins.vbguest.restart_vm"))
          @@rebooted[ VmCompatible.vm_id(vm) ] = true
        else
          vm.env.ui.warn(I18n.t("vagrant.plugins.vbguest.suggest_restart", :name => vm.name))
          false
        end
      end

      if Vagrant::VERSION < '1.1.0'

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

      else

        def reboot(vm, options)
          if reboot? vm, options
            simle_reboot = Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Action::Builtin::Call, Vagrant::Action::Builtin::GracefulHalt, :poweroff, :running do |env2, b2|
                if !env2[:result]
                  b2.use VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt
                end
              end
              b.use VagrantPlugins::ProviderVirtualBox::Action::Boot
            end
            @env[:action_runner].run(simle_reboot, @env)
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

    module VmCompatible

      if Vagrant::VERSION < '1.1.0'
        def communicate
          vm.channel
        end

        def driver
          vm.driver
        end

        def self.vm_id(vm)
          vm.uuid
        end

      else # Vagrant 1.1, and hopefully upwards
        def communicate
          vm.communicate
        end

        def driver
          vm.provider.driver
        end

        def self.vm_id(vm)
          vm.id
        end
      end
    end
  end
end
