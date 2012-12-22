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
      if options[:auto_update]
        machine = VagrantVbguest::Machine.new @vm, options
        status  = machine.state
        @vm.ui.send (:ok == status ? :success : :warn), I18n.t("vagrant.plugins.vbguest.status.#{status}", machine.info)
        machine.run
        reboot(@vm, options) if machine.reboot?
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
