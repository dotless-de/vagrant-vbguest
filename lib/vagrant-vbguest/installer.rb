module VagrantVbguest

  # Handles the guest addins installation process

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
      # Returns an instance of the registrated Installer class which
      # matches first (according to it's priority) or `nil` if none matches.
      def detect(vm, options)
        @installers.keys.sort.reverse.each do |prio|
          klass = @installers[prio].detect { |k| k.match?(vm) }
          return klass.new(vm, options) if klass
        end
        return nil
      end
    end

    def initialize(vm, options = {})
      @env = {
        :ui => vm.ui,
        :tmp_path => vm.env.tmp_path
      }
      @vm = vm
      @iso_path = nil
      @options = options
    end

    def run!
      @options[:auto_update] = true
      run
    end

    def run
      return unless @options[:auto_update]

      raise Vagrant::Errors::VMNotCreatedError if !@vm.created?
      raise Vagrant::Errors::VMInaccessible if !@vm.state == :inaccessible
      raise Vagrant::Errors::VMNotRunningError if @vm.state != :running

      @vm.ui.success(I18n.t("vagrant.plugins.vbguest.guest_ok", :version => guest_version)) unless needs_update?
      @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.check_failed", :host => vb_version, :guest => guest_version)) if @options[:no_install]

      if @options[:force] || (!@options[:no_install] && needs_update?)
        @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.installing#{@options[:force] ? '_forced' : ''}", :host => vb_version, :guest => guest_version))
        install
      end
    ensure
      cleanup
    end

    def install
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'install' if !installer

      # @vm.ui.info "Installing using #{installer.class.to_s}"
      installer.install do |type, data|
        @vm.ui.info(data, :prefix => false, :new_line => false)
      end
    end

    def rebuild
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'rebuild' if !installer

      installer.rebuild do |type, data|
        @vm.ui.info(data, :prefix => false, :new_line => false)
      end
    end

    def needs_rebuild?
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'check installation of' if !installer

      installer.needs_rebuild?
    end

    def need_reboot?
      installer = guest_installer
      raise NoInstallerFoundError, :method => 'check installation of' if !installer

      installer.need_reboot?
    end

    def needs_update?
      !(guest_version && vb_version == guest_version)
    end

    ##
    #
    # @return [String] The version code of the VirtualBox Guest Additions
    #                  available on the guest, or `nil` if none installed.
    def guest_version
      return @guest_version if @guest_version

      guest_version = @vm.driver.read_guest_additions_version
      guest_version = !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')

      @vm.channel.sudo('VBoxService --version', :error_check => false) do |type, data|
        if (v = data.to_s.match(/^(\d+\.\d+.\d+)/)) && guest_version != v[1]
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.guest_version_reports_differ", :driver => guest_version, :service => v[1]))
          guest_version = v[1]
        end
      end

      @guest_version = guest_version
    end

    # Returns the version code of the Virtual Box *host*
    def vb_version
      @vm.driver.version
    end

    # Returns an installer instance for the current vm
    # This is either the one configured via `installer` option or
    # detected from all registered installers (see {Installer.detect})
    #
    # @return [Installers::Base]
    def guest_installer
      @guest_installer ||= if @options[:installer].is_a? Class
        @options[:installer].new(@vm)
      else
        Installer.detect(@vm, @options)
      end
    end

    def cleanup
      @guest_installer.cleanup if @guest_installer
    end

  end
end
