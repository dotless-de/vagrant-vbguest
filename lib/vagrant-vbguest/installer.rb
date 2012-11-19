module VagrantVbguest

  # Handles the guest addins installation process

  class Installer
    @@rebooted = {}

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
        if rebooted?
          @vm.ui.error(I18n.t("vagrant.plugins.vbguest.restart_loop_guard_activated"))
        else
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.installing#{@options[:force] ? '_forced' : ''}", :host => vb_version, :guest => guest_version))
          install
        end
      end
    ensure
      cleanup
    end

    def install
      # :TODO:
      # the whole installation process should be put into own classes
      # like the vagrant system loading
      if (i_script = installer_script)
        @vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => iso_path, :to => iso_destination))
        @vm.channel.upload(iso_path, iso_destination)

        @vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_script", :from => File.basename(i_script), :to => installer_destination))
        @vm.channel.upload(i_script, installer_destination)

        @vm.channel.sudo("chmod 0755 #{installer_destination}") do |type, data|
          @vm.ui.info(data, :prefix => false, :new_line => false)
        end

        @vm.channel.sudo("#{installer_destination}") do |type, data|
          @vm.ui.info(data, :prefix => false, :new_line => false)
        end

        @vm.channel.execute("rm #{installer_destination} #{iso_destination}") do |type, data|
          @vm.ui.error(data.chomp, :prefix => false)
        end

        cleanup
        reboot
      end
    end

    def reboot
      if !VagrantVbguest::Helpers.kernel_module_running?(@vm)
        if @options[:auto_reboot]
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.restart_vm"))
          @@rebooted[@vm.name] = true
          @vm.reload
        else
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.suggest_restart", :name => @vm.name))
        end
      end
    end

    def rebooted?
      !!@@rebooted[@vm.name]
    end

    def needs_update?
      !(guest_version && vb_version == guest_version)
    end

    def guest_version
      guest_version = @vm.driver.read_guest_additions_version
      !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')
    end

    def vb_version
      @vm.driver.version
    end

    def installer_script
      platform = @vm.guest.distro_dispatch
      case platform
      when :debian, :ubuntu
        File.expand_path("../../../files/setup_debian.sh", __FILE__)
      when :gentoo, :redhat, :suse, :arch, :fedora, :linux
        @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.generic_install_script_for_platform", :platform => platform.to_s))
        File.expand_path("../../../files/setup_linux.sh", __FILE__)
      else
        @vm.ui.error(I18n.t("vagrant.plugins.vbguest.no_install_script_for_platform", :platform => platform.to_s))
        nil
      end
    end

    def installer_destination
      '/tmp/install_vbguest.sh'
    end

    def iso_destination
      '/tmp/VBoxGuestAdditions.iso'
    end

    def iso_path
      @iso_path ||= begin
        @options[:iso_path] ||= VagrantVbguest::Helpers.local_iso_path_for @vm, @options
        if !@options[:iso_path] || @options[:iso_path].empty? && !@options[:no_remote]
          @options[:iso_path] = VagrantVbguest::Helpers.web_iso_path_for @vm, @options
        end
        raise VagrantVbguest::IsoPathAutodetectionError if !@options[:iso_path] || @options[:iso_path].empty?
        @env[:iso_url] ||= @options[:iso_path].gsub '$VBOX_VERSION', vb_version

        if local_iso?
          @env[:iso_url]
        else
          # :TODO: This will also raise, if the iso_url points to an invalid local path
          raise VagrantVbguest::DownloadingDisabledError.new(:from => @env[:iso_url]) if @options[:no_remote]
          @download = VagrantVbguest::Download.new(@env)
          @download.download
          @download.temp_path
        end
      end
    end

    def local_iso?
      ::File.file?(@env[:iso_url])
    end

    def cleanup
      @download.cleanup if @download
    end

  end
end
