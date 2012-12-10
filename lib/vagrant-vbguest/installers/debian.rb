module VagrantVbguest
  module Installers
    class Debian < Linux

      def self.match?(vm)
        :debian == self.distro(vm)
      end

      # installes the correct linux-headers package
      # installes `dkms` package for dynamic kernel module loading
      def install(opts=nil, &block)
        install_cmd = 'apt-get install -y linux-headers-`uname -r` dkms'
        begin
          vm.channel.sudo(install_cmd, opts, &block)
        rescue
          vm.channel.sudo('apt-get update', opts, &block)
          vm.channel.sudo(install_cmd, opts, &block)
        end
        upload(iso_file)
        vm.channel.sudo("mount #{tmp_path} -o loop #{mount_point}", opts, &block)
        vm.channel.sudo("#{mount_point}/VBoxLinuxAdditions.run --nox11", opts, &block)
        vm.channel.sudo("umount #{mount_point}", opts, &block)
      end

    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Debian, 5)