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
        @@ditro[vm.uuid] ||= vm.guest.distro_dispatch
      end

      # Matches if the operating system name prints "Linux"
      # Raises an Error if this class is beeing subclassed but
      # this method was not overridden. This is considered an
      # error because, subclassed Installers usually indicate
      # a more specific distributen like 'ubuntu' or 'arch' and
      # therefore should do a more specific check.
      def self.match?(vm)
        raise Error, :_key => :do_not_inherit_match_method if self.class != Linux
        vm.channel.test("uname | grep 'Linux'")
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
      def install(iso_file = nil, opts=nil, &block)
        vm.ui.warn I18n.t("vagrant.plugins.vbguest.installer.generic_linux_installer")
        upload(iso_file)
        vm.channel.sudo("mount #{tmp_path} -o loop #{mount_point}", opts, &block)
        vm.channel.sudo("#{mount_point}/VBoxLinuxAdditions.run --nox11", opts, &block)
        vm.channel.sudo("umount #{mount_point}", opts, &block)
      end

      def installed?(opts=nil, &block)
        opts = {
          :sudo => true
        }.merge(opts || {})
        vm.channel.test('lsmod | grep vboxsf', opts, &block)
      end

      def rebuild(opts=nil, &block)
        vm.channel.sudo('/etc/init.d/vboxadd setup', opts, &block)
      end

    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Linux, 2)