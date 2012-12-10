module VagrantVbguest
  module Installers
    class Ubuntu < Debian

      def self.match?(vm)
        :ubuntu == self.distro(vm)
      end

    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Ubuntu, 5)