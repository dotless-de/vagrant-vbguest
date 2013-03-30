module VagrantVbguest

  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the
  # host system.

  class Middleware
    include VagrantVbguest::Helpers::Rebootable

    def initialize(app, env)
      @app = app
      @env = env
    end

    def call(env)
      @env    = env
      vm      = env[:vm] || env[:machine]

      options = vm.config.vbguest.to_hash.freeze

      if options[:auto_update]
        machine = VagrantVbguest::Machine.new vm, options
        status  = machine.state
        vm.env.ui.send((:ok == status ? :success : :warn), I18n.t("vagrant.plugins.vbguest.status.#{status}", machine.info))
        machine.run
        reboot(vm, options) if machine.reboot?
      end
      @app.call(env)
    end

  end
end
