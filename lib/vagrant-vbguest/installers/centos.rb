module VagrantVbguest
  module Installers
    class CentOS < Linux
      # Scientific Linux and CentOS show up as :redhat (or "centos7")
      # fortunately they're probably both similar enough to RHEL
      # (RedHat Enterprise Linux) not to matter.
      def self.match?(vm)
        /\A(centos)\d*\Z/ =~ self.distro(vm) ||
          communicate_to(vm).test('test -f /etc/centos-release')
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        install_kernel_dependencies!(opts, &block)
        super
      end

    protected
      def install_dependencies_cmd
        "yum install -y #{dependencies}"
      end

      def dependencies
        "gcc binutils make perl bzip2"
      end

      def install_kernel_dependencies!(opts=nil, &block)
        install_args = [
          'kernel-devel-`uname -r`',

          '--enablerepo=C`grep -oP \'\d+\.\d+\' /etc/centos-release`-base '\
            '--enablerepo=C`grep -oP \'\d+\.\d+\' /etc/centos-release`-updates kernel-devel',

          '--enablerepo=C*-base --enablerepo=C*-updates kernel-devel',
        ]

        begin
          return false if install_args.empty?

          cmd = "yum install -y #{install_args.shift}"
          communicate.sudo(cmd, opts, &block)
        rescue
          retry
        end
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::CentOS, 6)
