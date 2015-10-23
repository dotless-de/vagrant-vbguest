module VagrantVbguest
  module Installers
    class RedHat < Linux
      # Scientific Linux and CentOS show up as :redhat (or "centos7")
      # fortunately they're probably both similar enough to RHEL
      # (RedHat Enterprise Linux) not to matter.
      def self.match?(vm)
        /\A(redhat|centos)\d*\Z/ =~ self.distro(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      def install_dependencies_cmd
        "yum install -y #{dependencies}"
      end

      def dependencies
        packages = ['kernel-devel-`uname -r`', 'gcc', 'make', 'perl', 'bzip2']
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::RedHat, 5)
