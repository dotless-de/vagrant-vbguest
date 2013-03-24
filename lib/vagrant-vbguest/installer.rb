module VagrantVbguest

  ##
  # Dispatches the installation process to a rigistered
  # Installer implementation.
  class Installer

    class NoInstallerFoundError < Vagrant::Errors::VagrantError
      error_namespace "vagrant.plugins.vbguest.errors.installer"
      error_key "no_install_script_for_platform"
    end

    class << self

      ##
      # Register an Installer implementation.
      # All Installer classes which wish to get picked automaticly
      # using their `#match?` method have to register.
      # Ad-hoc or small custom Installer meight not need to get
      # registered, but need to get passed as an config option (`installer`)
      #
      # Registration takes a priority which defines how specific
      # the Installer matches a system. Low level installers, like
      # "linux" or "bsd" use a small priority (2), while distribution
      # installers use higher priority (5). Installers matching a
      # specific version of a distribution should use heigher
      # priority numbers.
      #
      # @param [Class] installer_class A reference to the Installer class.
      # @param [Fixnum] prio Priority describing how specific the Installer matches. (default: `5`)
      def register(installer_class, prio = 5)
        @installers ||= {}
        @installers[prio] ||= []
        @installers[prio] << installer_class
      end

      ##
      # Returns the class of the registrated Installer class which
      # matches first (according to it's priority) or `nil` if none matches.
      def detect(vm, options)
        @installers.keys.sort.reverse.each do |prio|
          klass = @installers[prio].detect { |k| k.match?(vm) }
          return klass if klass
        end
        return nil
      end
    end

    def initialize(vm, options = {})
      @vm = vm
      @env = vm.env
      @options = options
      @iso_path = nil
    end

    def install
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'install' if !installer

      installer.install do |type, data|
        @env.ui.info(data, :prefix => false, :new_line => false)
      end
    ensure
      cleanup
    end

    def rebuild
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'rebuild' if !installer

      installer.rebuild do |type, data|
        @env.ui.info(data, :prefix => false, :new_line => false)
      end
    end

    def start
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'manual start' if !installer

      installer.start do |type, data|
        @env.ui.info(data, :prefix => false, :new_line => false)
      end
    end

    def guest_version(reload=false)
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'check guest version of' if !installer
      installer.guest_version(reload)
    end

    def host_version
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'check host version of' if !installer
      installer.host_version
    end

    def running?
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'check current state of' if !installer
      installer.running?
    end

    # Returns an installer instance for the current vm
    # This is either the one configured via `installer` option or
    # detected from all registered installers (see {Installer.detect})
    #
    # @return [Installers::Base]
    def guest_installer
      @guest_installer ||= if @options[:installer].is_a? Class
        @options[:installer].new(@vm, @options)
      else
        installer_klass = Installer.detect(@vm, @options) and installer_klass.new(@vm, @options)
      end
    end

    def cleanup
      @guest_installer.cleanup if @guest_installer
    end

  end
end
