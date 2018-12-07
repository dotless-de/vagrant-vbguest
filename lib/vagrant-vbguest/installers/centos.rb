module VagrantVbguest
  module Installers
    class CentOS < RedHat

      def self.match?(vm)
        super && communicate_to(vm).test('test -f /etc/centos-release')
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        install_kernel_deps(opts, &block)
        super(opts=nil, &block)
      end

      protected
      def install_kernel_deps(opts=nil, &block)
        unless check_devel_info
          release = release_version
          update_release_repos(opts, &block)
          install_kernel_devel(release)
        end
      end

      def check_devel_info
        communicate.test('yum info kernel-devel-`uname -r`', { sudo: true })
      end

      def release_version
        release = nil
        communicate.sudo('cat /etc/centos-release') do |type, data|
         release = data.to_s[/(\d+\.\d+\.\d+)/, 1]
        end
        release
      end

      def update_release_repos(opts=nil, &block)
        communicate.sudo('yum install -y centos-release', opts, &block)
      end

      def install_kernel_devel(rel, opts=nil, &block)
        communicate.sudo(
            "yum install -y kernel-devel-`uname -r` --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates",
            opts,
            &block
        )
      end

      def dependencies
        packages = [ 'gcc', 'binutils', 'make', 'perl', 'bzip2' ]
        packages.join ' '
      end
    end
  end
end
# Load this before the RedHat one, as we want it to be picked up first. (The higher the sooner its checked).
VagrantVbguest::Installer.register(VagrantVbguest::Installers::CentOS, 6)
