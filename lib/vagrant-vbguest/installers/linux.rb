module VagrantVbguest
  module Installers
    # A basic Installer implementation for vanilla or
    # unknown Linux based systems.
    class Linux < Base

      # A helper method to cache the result of {Vagrant::Guest::Base#distro_dispatch}
      # which speeds up Installer detection runs a lot,
      # when having lots of Linux based Installer classes
      # to check.
      #
      # @see {Vagrant::Guest::Linux#distro_dispatch}
      # @return [Symbol] One of `:debian`, `:ubuntu`, `:gentoo`, `:fedora`, `:redhat`, `:suse`, `:arch`
      def self.distro(vm)
        @@ditro ||= {}
        @@ditro[ vm_id(vm) ] ||= distro_name vm
      end

      # Matches if the operating system name prints "Linux"
      # Raises an Error if this class is beeing subclassed but
      # this method was not overridden. This is considered an
      # error because, subclassed Installers usually indicate
      # a more specific distributen like 'ubuntu' or 'arch' and
      # therefore should do a more specific check.
      def self.match?(vm)
        raise Error, :_key => :do_not_inherit_match_method if self != Linux
        communicate_to(vm).test("uname | grep 'Linux'")
      end

      # The temporary path where to upload the iso file to.
      # Configurable via `config.vbguest.iso_upload_path`.
      # Defaults the temp path to `/tmp/VBoxGuestAdditions.iso" for
      # all Linux based systems
      def tmp_path
        options[:iso_upload_path] || '/tmp/VBoxGuestAdditions.iso'
      end

      # Mount point for the iso file.
      # Configurable via `config.vbguest.iso_mount_point`.
      #Ddefaults to "/mnt" for all Linux based systems.
      def mount_point
        options[:iso_mount_point] || '/mnt'
      end

      # a generic way of installing GuestAdditions assuming all
      # dependencies on the guest are installed
      #
      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(opts=nil, &block)
        env.ui.warn I18n.t("vagrant_vbguest.errors.installer.generic_linux_installer", distro: self.class.distro(vm)) if self.class == Linux
        upload(iso_file)
        mount_iso(opts, &block)
        execute_installer(opts, &block)
        unmount_iso(opts, &block) unless options[:no_cleanup]
      end

      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def running?(opts=nil, &block)
        opts = {
          :sudo => true
        }.merge(opts || {})
        communicate.test('lsmod | grep vboxsf', opts, &block)
      end

      # This overrides {VagrantVbguest::Installers::Base#guest_version}
      # to also query the `VBoxService` on the host system (if available)
      # for it's version.
      # In some scenarios the results of the VirtualBox driver and the
      # additions installed on the host may differ. If this happens, we
      # assume, that the host binaries are right and yield a warning message.
      #
      # @return [String] The version code of the VirtualBox Guest Additions
      #                  available on the guest, or `nil` if none installed.
      def guest_version(reload = false)
        return @guest_version if @guest_version && !reload
        driver_version = super

        communicate.sudo('VBoxService --version', :error_check => false) do |type, data|
          if (v = data.to_s.match(/^(\d+\.\d+.\d+)/)) && driver_version != v[1]
            @env.ui.warn(I18n.t("vagrant_vbguest.guest_version_reports_differ", :driver => driver_version, :service => v[1]))
            @guest_version = v[1]
          end
        end
        @guest_version
      end

      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def rebuild(opts=nil, &block)
        communicate.sudo("#{vboxadd_tool} setup", opts, &block)
      end

      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def start(opts=nil, &block)
        opts = {:error_check => false}.merge(opts || {})
        systemd = systemd_tool
        if systemd
          communicate.sudo("#{systemd[:path]} vboxadd #{systemd[:up]}", opts, &block)
        else
          communicate.sudo("#{vboxadd_tool} start", opts, &block)
        end
      end

      # Check for the presence of 'systemd' chkconfg or service command.
      #
      #    systemd_tool # => {:path=>"/usr/sbin/service", :up=>"start"}
      #
      # @return [Hash|nil] Hash with an absolute +path+ to the tool and the
      #                    command string for starting.
      #                    +nil* if neither was found.
      def systemd_tool
        result = nil
        communicate.sudo('(which chkconfg || which service) 2>/dev/null', {:error_check => false}) do |type, data|
          path = data.to_s
          case path
          when /\bservice\b/
            result = { path: path, up: "start" }
          when /\chkconfg\b/
            result = { path: path, up: "on" }
          end
        end
        result
      end

      # Checks for the correct location of the 'vboxadd' tool.
      # It checks for a given list of possible locations. This list got
      # extracted from the 'VBoxLinuxAdditions.run' script.
      #
      # @return [String|nil] Absolute path to the +vboxadd+ tool,
      #                      or +nil+ if none found.
      def vboxadd_tool
        candidates = [
          "/usr/lib/i386-linux-gnu/VBoxGuestAdditions/vboxadd",
          "/usr/lib/x86_64-linux-gnu/VBoxGuestAdditions/vboxadd",
          "/usr/lib64/VBoxGuestAdditions/vboxadd",
          "/usr/lib/VBoxGuestAdditions/vboxadd",
          "/lib64/VBoxGuestAdditions/vboxadd",
          "/lib/VBoxGuestAdditions/vboxadd",
          "/etc/init.d/vboxadd",
        ]
        bin_path = ""
        cmd = <<-SHELL
        for c in #{candidates.join(" ")}; do
          if test -x "$c"; then
            echo $c
            break
          fi
        done
        SHELL

        path = nil
        communicate.sudo(cmd, {:error_check => false}) do |type, data|
          path = data.strip unless data.empty?
        end
        path
      end

      # A generic helper method to execute the installer.
      # This also yields a installation warning to the user, and an error
      # warning in the event that the installer returns a non-zero exit status.
      #
      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def execute_installer(opts=nil, &block)
        yield_installation_waring(installer)
        opts = {:error_check => false}.merge(opts || {})
        exit_status = communicate.sudo("#{installer} #{installer_arguments}", opts, &block)
        yield_installation_error_warning(installer) unless exit_status == 0
        exit_status
      end

      # The absolute path to the GuestAdditions installer script.
      # The iso file has to be mounted on +mount_point+.
      def installer
        @installer ||= File.join(mount_point, 'VBoxLinuxAdditions.run')
      end

      # The arguments string, which gets passed to the installer script
      def installer_arguments
        @installer_arguments ||= Array(options[:installer_arguments]).join " "
      end

      # A generic helper method for mounting the GuestAdditions iso file
      # on most linux system.
      # Mounts the given uploaded file from +tmp_path+ on +mount_point+.
      #
      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def mount_iso(opts=nil, &block)
        communicate.sudo("mount #{tmp_path} -o loop #{mount_point}", opts, &block)
      end

      # A generic helper method for un-mounting the GuestAdditions iso file
      # on most linux system
      # Unmounts the +mount_point+.
      #
      # @param opts [Hash] Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def unmount_iso(opts=nil, &block)
        communicate.sudo("umount #{mount_point}", opts, &block)
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Linux, 2)
