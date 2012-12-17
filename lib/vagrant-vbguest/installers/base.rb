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

      attr_reader :vm

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
      # Subclasses must override this method!
      #
      # @param [String] iso_file Optional path to the local GuestAdditions iso file
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(iso_fileO=nil, opts=nil, &block)
      end

      # Handels the rebuild of allready installed GuestAdditions
      # It may happen, that the guest has the correct GuestAdditions
      # version installed, but not the kernel module is not loaded.
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

      # Determinates if the GuestAdditions kernel module is loaded.
      # This method tests if there is a working GuestAdditions
      # kernel module. If there is none, {#rebuild} is beeing called.
      # If there is no way of telling if there is a working
      # GuestAddition for a specific system, this method should
      # return `true`.
      # Subclasses should override this method.
      #
      # @return [Boolean] `true` if the kernel module is loaded (and thus seems to work), `false` otherwise.
      def installed?(opts=nil, &block)
        true
      end

      def needs_rebuild?(opts=nil, &block)
        !installed?(opts, &block)
      end

      def needs_reboot?(opts=nil, &block)
        !installed?(opts, &block)
      end

      def iso_file
        @iso_file ||= begin
          iso_path = @options[:iso_path] || local_iso_path

          if !iso_path || iso_path.empty? && !@options[:no_remote]
            iso_path = VagrantVbguest::Helpers.web_iso_path_for @vm, @options
          end
          raise VagrantVbguest::IsoPathAutodetectionError if !iso_path || iso_path.empty?

          iso_path.gsub! '$VBOX_VERSION', vm.driver.version
          if Vagrant::Downloaders::File.match? iso_path
            iso_path
          else
            # :TODO: This will also raise, if the iso_url points to an invalid local path
            raise VagrantVbguest::DownloadingDisabledError.new(:from => iso_url) if @options[:no_remote]
            env = {
              :ui => vm.ui,
              :tmp_path => vm.env.tmp_path,
              :iso_url => iso_url
            }
            @download = VagrantVbguest::Download.new(@env)
            @download.download
            @download.temp_path
          end
        end
      end

      def local_iso?
        ::File.file?(@env[:iso_url])
      end

      def local_iso_path
        media_manager_iso || guess_iso
      end

      def web_iso_path
        "http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso"
      end

      def media_manager_iso
        (m = vm.driver.execute('list', 'dvds').match(/^.+:\s+(.*VBoxGuestAdditions.iso)$/i)) && m[1]
      end

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
      def upload(file)
        vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => file, :to => tmp_path))
        vm.channel.upload(file, tmp_path)
      end

      # A helper method to delete the uploaded GuestAdditions iso file
      # from the guest
      def cleanup
        @download.cleanup if @download

        vm.channel.execute("rm #{tmp_path}", :error_check => false) do |type, data|
          vm.ui.error(data.chomp, :prefix => false)
        end
      end

    end
  end
end