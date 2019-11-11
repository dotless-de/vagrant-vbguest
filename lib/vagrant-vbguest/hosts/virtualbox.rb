module VagrantVbguest
  module Hosts
    class VirtualBox < Base

      def read_guest_additions_version
        # this way of checking for the GuestAdditionsVersion is taken from Vagrant's
        # `read_guest_additions_version` method introduced via
        # https://github.com/hashicorp/vagrant/commit/d8ff2cb5adca25d7eba2bdd334919770316c91be
        # for VirtualBox 4.2 and carries on for later versons until now
        # We are vendoring it here, since Vagrant uses it is only a fallback
        # for when `guestproperty` won't work. But `guestproperty` seems to be prone
        # to return incorrect values.
        if Gem::Requirement.new(">= 4.2").satisfied_by? Gem::Version.new(version)
          uuid = self.class.vm_id(vm)
          begin
            info = driver.execute("showvminfo", uuid, "--machinereadable", retryable: true)
            info.split("\n").each do |line|
              return $1.to_s if line =~ /^GuestAdditionsVersion="(.+?)"$/
            end
          rescue Vagrant::Errors::VBoxManageError => e
            if e.message =~ /Invalid command.*showvminfo/i
              vm.env.ui.warn("Cannot read GuestAdditionsVersion using 'showvminfo'")
              vm.env.ui.debug(e.message)
            else
              raise e
            end
          end
        end

        super
      end

      protected

        # Default web URI, where GuestAdditions iso file can be downloaded.
        #
        # @return [String] A URI template containing the versions placeholder.
        def web_path
          "https://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso"
        end


        # Finds GuestAdditions iso file on the host system.
        # Returns +nil+ if none found.
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def local_path
          media_manager_iso || guess_local_iso
        end

        # Kicks off +VagrantVbguest::Download+ to download the additions file
        # into a temp file.
        #
        # To remove the created tempfile call +cleanup+
        #
        # @param path [String] The path or URI to download
        #
        # @return [String] The path to the downloaded file
        def download(path)
          temp_path = File.join(@env.tmp_path, "VBoxGuestAdditions_#{version}.iso")
          @download = VagrantVbguest::Download.new(path, temp_path, :ui => @env.ui)
          @download.download!
          @download.destination
        end

      private

        # Helper method which queries the VirtualBox media manager
        # for the first existing path that looks like a
        # +VBoxGuestAdditions.iso+ file.
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def media_manager_iso
          driver.execute('list', 'dvds').scan(/^.+:\s+(.*VBoxGuestAdditions(?:_#{version})?\.iso)$/i).map { |path, _|
            path if File.exist?(path)
          }.compact.first
        end

        # Find the first GuestAdditions iso file which exists on the host system
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def guess_local_iso
          Array(platform_path).find do |path|
            path && File.exists?(path)
          end
        end

        # Makes an educated guess where the GuestAdditions iso file
        # could be found on the host system depending on the OS.
        # Returns +nil+ if no the file is not in it's place.
        def platform_path
          [:linux, :darwin, :cygwin, :windows].each do |sys|
            return self.send("#{sys}_path") if Vagrant::Util::Platform.respond_to?("#{sys}?") && Vagrant::Util::Platform.send("#{sys}?")
          end
          nil
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on linux based systems
        def linux_path
          paths = [
            "/usr/share/virtualbox/VBoxGuestAdditions.iso",
            "/usr/lib/virtualbox/additions/VBoxGuestAdditions.iso"
          ]
          paths.unshift(File.join(ENV['HOME'], '.VirtualBox', "VBoxGuestAdditions_#{version}.iso")) if ENV['HOME']
          paths
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on Macs
        def darwin_path
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on windows systems
        def windows_path
          if (p = ENV["VBOX_INSTALL_PATH"] || ENV["VBOX_MSI_INSTALL_PATH"]) && !p.empty?
            File.join(p, "VBoxGuestAdditions.iso")
          elsif (p = ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]) && !p.empty?
            File.join(p, "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
          end
        end
        alias_method :cygwin_path, :windows_path

        # overwrite the default version string to allow lagacy
        # '$VBOX_VERSION' as a placerholder
        def versionize(path)
          super(path.gsub('$VBOX_VERSION', version))
        end

    end
  end
end
