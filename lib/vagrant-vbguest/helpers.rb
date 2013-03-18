module VagrantVbguest
  module Helpers
    module Rebootable
      @@rebooted = {}

      def rebooted?(vm)
        !!@@rebooted[vm.id]
      end

      def reboot(vm, options)
        if rebooted?(vm)
          vm.ui.error(I18n.t("vagrant.plugins.vbguest.restart_loop_guard_activated"))
          false
        elsif options[:auto_reboot]
          vm.ui.warn(I18n.t("vagrant.plugins.vbguest.restart_vm"))
          @@rebooted[vm.id] = true
        else
          vm.ui.warn(I18n.t("vagrant.plugins.vbguest.suggest_restart", :name => vm.name))
          false
        end
      end
    end

  end
end