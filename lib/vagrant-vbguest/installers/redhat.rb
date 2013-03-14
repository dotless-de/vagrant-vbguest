module VagrantVbguest
  module Installers
    class RedHat < Linux
      # Scientific Linux (and probably CentOS) both show up as :redhat
      # fortunately they're probably both similar enough to RHEL
      # (RedHat Enterprise Linux) not to matter.
      def self.match?(vm)
        :redhat == self.distro(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        vm.channel.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      def install_dependencies_cmd
        "yum install -y #{dependencies}"
      end

      def dependencies
        packages = ['kernel-devel-`uname -r`', 'gcc', 'make', 'perl']
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::RedHat, 5)

# vim: ts=2 sw=2 et
