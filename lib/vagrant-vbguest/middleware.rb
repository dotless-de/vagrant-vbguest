module VagrantVbguest

  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the
  # host system.

  class Middleware
    include VagrantVbguest::Helpers::Rebootable

    def initialize(app, env, options = {})
      @app = app
      @env = env
      @vm  = env[:vm]
    end

    def call(env)
      options = @vm.config.vbguest.to_hash
      installer = VagrantVbguest::Installer.new(@vm, options)
      installer.run

      if installer.needs_reboot?
        if rebooted?(@vm)
          @vm.ui.error(I18n.t("vagrant.plugins.vbguest.restart_loop_guard_activated"))
        else
          reboot(@vm, options)
        end
      end

      @app.call(env)
    end

    def reboot vm, options
      if super
        @env[:action_runner].run(Vagrant::Action::VM::Halt, @env)
        @env[:action_runner].run(Vagrant::Action::VM::Boot, @env)
      end
    end

  end
end
