module VagrantVbguest
  module Helpers

    module Rebootable
      @@rebooted = {}

      def rebooted?(vm)
        !!@@rebooted[ VmCompatible.vm_id(vm) ]
      end

      def reboot(vm, options)
        run_reboot = if rebooted?(vm)
          vm.env.ui.error(I18n.t("vagrant.plugins.vbguest.restart_loop_guard_activated"))
          false
        elsif options[:auto_reboot]
          vm.env.ui.warn(I18n.t("vagrant.plugins.vbguest.restart_vm"))
          @@rebooted[ VmCompatible.vm_id(vm) ] = true
        else
          vm.env.ui.warn(I18n.t("vagrant.plugins.vbguest.suggest_restart", :name => vm.name))
          false
        end
        return unless run_reboot

        if Vagrant::VERSION < '1.1.0'
          vm.reload(options)
        else
          vm.action(:reload, options)
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
