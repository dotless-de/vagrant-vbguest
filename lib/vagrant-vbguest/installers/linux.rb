module VagrantVbguest
  module Installers
    # A basic Installer implementation for vanilla or
    # unknown Linux based systems.
    class Linux < Base

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

      # defaults the temp path to "/tmp/VBoxGuestAdditions.iso" for all Linux based systems
      def tmp_path
        '/tmp/VBoxGuestAdditions.iso'
      end

      # defaults the mount point to "/mnt" for all Linux based systems
      def mount_point
        '/mnt'
      end

      # a generic way of installing GuestAdditions assuming all
      # dependencies on the guest are installed
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(opts=nil, &block)
        env.ui.warn I18n.t("vagrant_vbguest.errors.installer.generic_linux_installer") if self.class == Linux
        upload(iso_file)
        mount_iso(opts, &block)
        execute_installer(opts, &block)
        unmount_iso(opts, &block)
      end

      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
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

      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def rebuild(opts=nil, &block)
        communicate.sudo('/etc/init.d/vboxadd setup', opts, &block)
      end

      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def start(opts=nil, &block)
        opts = {:error_check => false}.merge(opts || {})
        communicate.sudo('/etc/init.d/vboxadd start', opts, &block)
      end


      # A generic helper method to execute the installer.
      # This also yields a installation warning to the user, and an error
      # warning in the event that the installer returns a non-zero exit status.
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
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
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
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
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
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
