module VagrantVbguest
  module Installers
    class Oracle < RedHat

      def self.match?(vm)
        :redhat == self.distro(vm) &&
          communicate_to(vm).test('test -f /etc/oracle-release')
      end

      protected

      def dependencies
        ['kernel-uek-devel-`uname -r`', 'gcc', 'make', 'perl', 'bzip2'].join(' ')
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Oracle, 6)
