module VagrantVbguest
  module Helpers

    module Rebootable
      include VmCompatible
      def self.included(base)
        base.extend(ClassMethods)
      end

      @@rebooted = {}

      def rebooted?(vm)
        !!@@rebooted[ self.class.vm_id(vm) ]
      end

      def reboot?(vm, options)
        if rebooted?(vm)
          vm.env.ui.error(I18n.t("vagrant_vbguest.restart_loop_guard_activated"))
          false
        elsif options[:auto_reboot]
          vm.env.ui.warn(I18n.t("vagrant_vbguest.restart_vm"))
          @@rebooted[ self.class.vm_id(vm) ] = true
        else
          vm.env.ui.warn(I18n.t("vagrant_vbguest.suggest_restart", :name => vm.name))
          false
        end
      end

      def reboot(vm, options)
        raise NotImplementedError
      end

      def reboot!(vm, options)
        raise NotImplementedError
      end
    end

  end
end
