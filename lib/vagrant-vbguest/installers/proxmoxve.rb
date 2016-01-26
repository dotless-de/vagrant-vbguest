module VagrantVbguest
  module Installers
    class ProxmoxVE < Debian

      def self.match?(vm)
        communicate_to(vm).test('test -f /etc/pve/.version')
      end

    protected
      def headers_package_name_prefix
        'pve-headers-'
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::ProxmoxVE, 6)
