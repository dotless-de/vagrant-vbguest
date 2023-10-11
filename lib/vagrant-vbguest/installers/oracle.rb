module VagrantVbguest
  module Installers
    class Oracle < RedHat

      def self.match?(vm)
        :redhat == self.distro(vm) &&
          communicate_to(vm).test('test -f /etc/oracle-release')
      end

      protected

      def dependencies
        [
          'kernel-`uname -a | grep -q "uek." && echo "uek-"`devel-`uname -r`',
          'gcc',
          'make',
          'perl',
          'bzip2',
          'elfutils-libelf-devel'
        ].join(' ')
      end
    end
  end
end
VagrantVbguest::Installer.register(:oracle, VagrantVbguest::Installers::Oracle, 6)
VagrantVbguest::Installer.register(:oraclelinux, VagrantVbguest::Installers::Oracle, 6)
VagrantVbguest::Installer.register(:oracle_linux, VagrantVbguest::Installers::Oracle, 6)
