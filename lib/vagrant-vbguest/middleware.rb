module VagrantVbguest

  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the
  # host system.

  class Middleware
    def initialize(app, env, options = {})
      @app = app
      @env = env
      @vm  = env[:vm]
    end

    def call(env)
      options = @vm.config.vbguest.to_hash
      VagrantVbguest::Installer.new(@vm, options).run

      @app.call(env)
    end

  end
end
