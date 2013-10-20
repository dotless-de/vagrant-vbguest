module VagrantVbguest
  module Installers
    class Ubuntu < Debian

      def self.match?(vm)
        :ubuntu == self.distro(vm)
      end

      def install(opts=nil, &block)
        remove_packaged_additions(opts=nil, &block)
        super
      end

    protected

      def remove_packaged_additions(opts=nil, &block)
        options = (opts || {}).merge(:error_check => false)
        command = "dpkg --list | grep virtualbox-guest && apt-get -y -q purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11"
        communicate.sudo(command, options, &block)
      end

    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Ubuntu, 5)
