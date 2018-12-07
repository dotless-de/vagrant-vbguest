module VagrantVbguest
  module Installers
    class CentOS < Linux

      def self.match?(vm)
        /\A(centos)\d*\Z/ =~ self.distro(vm) &&
            communicate_to(vm).test('test -f /etc/centos-release')
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        install_kernel_deps
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

      protected
      def install_kernel_deps
        unless check_devel_info
          update_release_repos
          release = release_version
          install_kernel_devel(release)
        end
      end

      def check_devel_info
        communicate.test('yum info kernel-devel-`uname -r`', { sudo: true })
      end

      def update_release_repos
        communicate.sudo('yum install -y centos-release')
      end

      def release_version
        communicate.sudo('cat /etc/centos-release') do |type, data|
          data.to_s[/(\d+\.\d+\.\d+)/, 1]
        end
      end

      def install_kernel_devel(rel)
        communicate.sudo("yum install -y kernel-devel-`uname -r` --enablerepo=C#{rel}-base")
      end

      def install_dependencies_cmd
        "yum install -y #{dependencies}"
      end

      def dependencies
        packages = [ 'gcc', 'binutils', 'make', 'perl', 'bzip2' ]
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::CentOS, 5)
