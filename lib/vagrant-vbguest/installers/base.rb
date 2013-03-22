module VagrantVbguest
  module Installers
    class Error < Vagrant::Errors::VagrantError
      error_namespace "vagrant.plugins.vbguest.errors.installer"
    end

    # This is the base class all installers must inherit from
    # It defines the basic structure of an Installer and should
    # never be used directly
    class Base

      # Tests whether this installer class is applicable to the
      # current environment. Usually, testing for a specific OS.
      # Subclasses must override this method and return `true` if
      # they wish to handle.
      #
      # This method will be called only when an Installer detection
      # is run. It is ignored, when passing an Installer class
      # directly as an config (`installer`) option.
      #
      # @param [Vagrant::VM]
      # @return [Boolean]
      def self.match?(vm)
        false
      end

      attr_reader :vm, :options

      def initialize(vm, options=nil)
        @vm = vm
        @options = options
      end

      # The absolute file path of the GuestAdditions iso file should
      # be uploaded into the guest.
      # Subclasses must override this method!
      #
      # @return [String]
      def tmp_path
      end

      # The mountpoint path
      # Subclasses shall override this method, if they need to mount the uploaded file!
      #
      # @retunn [String]
      def mount_point
      end

      # Handles the installation process.
      # All necessary steps for an installation must be defined here.
      # This includes uploading the iso into the box, mounting,
      # installing and cleaning up.
      # The path to the local iso file should be obtained by calling +iso_file+
      # Subclasses must override this method!
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(opts=nil, &block)
      end

      # Handels the rebuild of allready running GuestAdditions
      # It may happen, that the guest has the correct GuestAdditions
      # version running, but not the kernel module is not running.
      # This method should perform a rebuild or try to reload the
      # kernel module _without_ the GuestAdditions iso file.
      # If there is no way of rebuidling or reloading the
      # GuestAdditions on a specific system, this method should left
      # empty.
      # Subclasses should override this method.
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def rebuild(opts=nil, &block)
      end

      # Restarts the allready installed GuestAdditions
      # It may happen, that the guest has the correct GuestAdditions
      # version installed, but for some reason are not (yet) runnig.
      # This method should execute the GuestAdditions system specific
      # init script in order to start it manually.
      # If there is no way of doing this on a specific system,
      # this method should left empty.
      # Subclasses should override this method.
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def start(opts=nil, &block)
      end

      # Determinates if the GuestAdditions kernel module is loaded.
      # This method tests if there is a working GuestAdditions
      # kernel module. If there is none, {#rebuild} is beeing called.
      # If there is no way of telling if there is a working
      # GuestAddition for a specific system, this method should
      # return `true`.
      # Subclasses should override this method.
      #
      # @return [Boolean] `true` if the kernel module is loaded (and thus seems to work), `false` otherwise.
      def running?(opts=nil, &block)
        true
      end

      # Determinates the GuestAdditions version installed on the
      # guest system.
      #
      # @param [Boolean] reload Whether to read the value again or use
      #                  the cached value form an erlier call.
      # @return [String] The version code of the VirtualBox Guest Additions
      #                  available on the guest, or `nil` if none installed.
      def guest_version(reload=false)
        return @guest_version if @guest_version && !reload

        guest_version = vm.driver.read_guest_additions_version
        guest_version = !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')

        @guest_version = guest_version
      end

      # Determinates the host's version
      #
      # @return [String] The version code of the Virtual Box *host*
      def host_version
        vm.driver.version
      end

      # Determinates the version of the GuestAdditions installer in use
      #
      # @return [String] The version code of the GuestAdditions installer
      def installer_version(path_to_installer)
        version = nil
        @vm.channel.sudo("#{path_to_installer} --info", :error_check => false) do |type, data|
          if (v = data.to_s.match(/\AIdentification.*\s(\d+\.\d+.\d+)/i))
            version = v[1]
          end
        end
        version
      end

      # Helper to yield a warning message to the user, that the installation
      # will start _now_.
      # The message includes the host and installer version strings.
      def yield_installation_waring(path_to_installer)
        @vm.ui.warn I18n.t("vagrant.plugins.vbguest.installing#{@options[:force] ? '_forced' : ''}",
          :guest_version => guest_version,
          :installer_version => installer_version(path_to_installer) || I18n.t("vagrant.plugins.vbguest.unknown"))
      end

      # Helper to yield a warning message to the user, that the installation
      # will be rebuild using the installed GuestAdditions.
      # The message includes the host and installer version strings.
      def yield_rebuild_warning
        @vm.ui.warn I18n.t("vagrant.plugins.vbguest.rebuild#{@options[:force] ? '_forced' : ''}",
          :guest_version => guest_version(true),
          :host_version => host_version)
      end

      # Helper to yield a warning message to the user in the event that the
      # installer returned a non-zero exit status. Because lack of a window
      # system will cause this result in VirtualBox 4.2.8+, we don't want to
      # kill the entire boot process, but we do want to make sure the user
      # knows there could be a problem. The message includles the installer
      # version.
      def yield_installation_error_warning(path_to_installer)
        @vm.ui.warn I18n.t("vagrant.plugins.vbguest.install_error",
          :installer_version => installer_version(path_to_installer) || I18n.t("vagrant.plugins.vbguest.unknown"))
      end

      # GuestAdditions-iso-file-detection-magig.
      #
      # Detectio runs in those stages:
      # 1. Uses the +iso_path+ config option, if present and not set to +:auto+
      # 2. Look out for a local iso file
      # 3. Use the default web URI
      #
      # If the detected or configured path is not a local file and remote downloads
      # are allowed (the config option +:no_remote+ is NOT set) it will try to
      # download that file into a temp file using Vagrants Downloaders.
      # If remote downloads are prohibited (the config option +:no_remote+ IS set)
      # a +VagrantVbguest::IsoPathAutodetectionError+ will be thrown
      #
      # @return [String] A absolute path to the GuestAdditions iso file.
      #                  This might be a temp-file, e.g. when downloaded from web.
      def iso_file
        @iso_file ||= begin
          iso_path = options[:iso_path]
          if !iso_path || iso_path.empty? || iso_path == :auto
            iso_path = local_iso_path
            iso_path = web_iso_path if !iso_path || iso_path.empty? && !options[:no_remote]
          end
          raise VagrantVbguest::IsoPathAutodetectionError if !iso_path || iso_path.empty?

          version = host_version
          iso_path = iso_path.gsub('$VBOX_VERSION', version) % {:version => version}
          if Vagrant::Downloaders::File.match? iso_path
            iso_path
          else
            # :TODO: This will also raise, if the iso_url points to an invalid local path
            raise VagrantVbguest::DownloadingDisabledError.new(:from => iso_path) if options[:no_remote]
            env = {
              :ui => vm.ui,
              :tmp_path => vm.env.tmp_path,
              :iso_url => iso_path
            }
            @download = VagrantVbguest::Download.new(env)
            @download.download
            @download.temp_path
          end
        end
      end

      # Default web URI, where GuestAdditions iso file can be downloaded.
      #
      # @return [String] A URI template containing the versions placeholder.
      def web_iso_path
        "http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso"
      end

      # Finds GuestAdditions iso file on the host system.
      # Returns +nil+ if none found.
      #
      # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
      def local_iso_path
        media_manager_iso || guess_iso
      end

      # Helper method which queries the VirtualBox media manager
      # for a +VBoxGuestAdditions.iso+ file.
      # Returns +nil+ if none found.
      #
      # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
      def media_manager_iso
        (m = vm.driver.execute('list', 'dvds').match(/^.+:\s+(.*VBoxGuestAdditions(?:_#{guest_version})?\.iso)$/i)) && m[1]
      end

      # Makes an educated guess where the GuestAdditions iso file
      # could be found on the host system depending on the OS.
      # Returns +nil+ if no the file is not in it's place.
      #
      # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
      def guess_iso
        path_platform = if Vagrant::Util::Platform.linux?
          "/usr/share/virtualbox/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.darwin?
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.windows?
          if (p = ENV["VBOX_INSTALL_PATH"]) && !p.empty?
            File.join(p, "VBoxGuestAdditions.iso")
          else
            File.join((ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]), "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
          end
        end
        File.exists?(path_platform) ? path_platform : nil
      end

      # A helper method to handle the GuestAdditions iso file upload
      # into the guest box.
      # The file will uploaded to the location given by the +tmp_path+ method.
      #
      # @example Default upload
      #    upload(iso_file)
      #
      # @param [String] Path of the file to upload to the +tmp_path*
      def upload(file)
        vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => file, :to => tmp_path))
        vm.channel.upload(file, tmp_path)
      end

      # A helper method to delete the uploaded GuestAdditions iso file
      # from the guest box
      def cleanup
        @download.cleanup if @download
        vm.channel.execute("test -f #{tmp_path} && rm #{tmp_path}", :error_check => false) do |type, data|
          vm.ui.error(data.chomp, :prefix => false)
        end
      end

    end
  end
end
