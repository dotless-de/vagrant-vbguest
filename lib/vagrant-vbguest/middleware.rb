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

      options = override_config(vm.config.vbguest.to_hash).freeze

      if options[:auto_update]
        machine = VagrantVbguest::Machine.new vm, options
        status  = machine.state
        vm.env.ui.send((:ok == status ? :success : :warn), I18n.t("vagrant_vbguest.status.#{status}", machine.info))
        machine.run
        reboot(vm, options) if machine.reboot?
      end
    rescue VagrantVbguest::Installer::NoInstallerFoundError => e
      vm.env.ui.error e.message
    ensure
      @app.call(env)
    end

    def override_config(opts)
      if opts[:auto_reboot] && Vagrant::VERSION.between?("1.1.0", "1.1.5") && Vagrant::VERSION != "1.1.4"
        @env[:ui].warn I18n.t("vagrant_vbguest.vagrant_11_reload_issues")
        opts.merge!({:auto_reboot => false})
      end
      opts
    end

  end
end
