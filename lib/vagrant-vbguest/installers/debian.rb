module VagrantVbguest
  module Installers
    class Debian < Linux

      def self.match?(vm)
        :debian == self.distro(vm)
      end

      # installes the correct linux-headers package
      # installes `dkms` package for dynamic kernel module loading
      def install(opts=nil, &block)
        begin
          vm.channel.sudo(install_dependencies_cmd, opts, &block)
        rescue
          vm.channel.sudo('apt-get update', opts, &block)
          vm.channel.sudo(install_dependencies_cmd, opts, &block)
        end
        upload(iso_file)
        vm.channel.sudo("mount #{tmp_path} -o loop #{mount_point}", opts, &block)
        vm.channel.sudo("#{mount_point}/VBoxLinuxAdditions.run --nox11", opts, &block)
        vm.channel.sudo("umount #{mount_point}", opts, &block)
      end

    protected
      def install_dependencies_cmd
        "apt-get install -y #{dependencies}"
      end

      def dependencies
        packages = ['linux-headers-`uname -r`']
        # some Debian system (lenny) dont come with a dkms packe so we neet to skip that.
        # apt-cache search will exit with 0 even if nothing was found, so we need to grep.
        packages << 'dkms' if vm.channel.test('apt-cache search --names-only \'^dkms$\' | grep dkms')
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Debian, 5)