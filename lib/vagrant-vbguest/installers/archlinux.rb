module VagrantVbguest
  module Installers
    class Archlinux < Linux

      def self.match?(vm)
        :arch == self.distro(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        # Update the package list
        communicate.sudo("pacman -Sy", opts, &block)
        # Install the dependencies
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

      protected
      def install_dependencies_cmd
        "pacman -S #{dependencies} --noconfirm --needed"
      end

      def dependencies
        packages = ['gcc', 'dkms', 'make', 'bzip2']
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Archlinux, 5)
