module VagrantVbguest
  module Helpers
    module Rebootable
      @@rebooted = {}

      def rebooted?(vm)
        !!@@rebooted[vm.name]
      end

      def reboot(vm, options)
        if options[:auto_reboot]
          vm.ui.warn(I18n.t("vagrant.plugins.vbguest.restart_vm"))
          @@rebooted[vm.name] = true
          true
        else
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.suggest_restart", :name => vm.name))
          false
        end
      end
    end

  end
end