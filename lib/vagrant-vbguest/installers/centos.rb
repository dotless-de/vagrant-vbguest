module VagrantVbguest
  module Installers
    class CentOS < RedHat

      def self.match?(vm)
        super && communicate_to(vm).test('test -f /etc/centos-release')
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        install_kernel_deps(opts, &block)
        super
      end

      protected

      def install_kernel_deps(opts=nil, &block)
        unless has_kernel_devel_info?
          update_release_repos(opts, &block)
          install_kernel_devel(opts, &block)
        end
      end

      def has_kernel_devel_info?
        unless instance_variable_defined?(:@has_kernel_devel_info)
          @has_kernel_devel_info = communicate.test('yum info kernel-devel-`uname -r`', sudo: true)
        end
        @has_kernel_devel_info
      end

      def has_rel_repo?
        unless instance_variable_defined?(:@has_rel_repo)
          rel = release_version
          @has_rel_repo = communicate.test("yum repolist --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates")
        end
        @has_rel_repo
      end

      def release_version
        unless instance_variable_defined?(:@release_version)
          @release_version = nil
          communicate.sudo('cat /etc/centos-release') do |type, data|
            @release_version = data.to_s[/(\d+\.\d+(\.\d+)?)/, 1]
          end
        end
        @release_version
      end

      def update_release_repos(opts=nil, &block)
        communicate.sudo('yum install -y centos-release', opts, &block)
      end

      def install_kernel_devel(opts=nil, &block)
        rel = has_rel_repo? ? release_version : '*'
        cmd = "yum install -y kernel-devel-`uname -r` --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates"
        communicate.sudo(cmd, opts, &block)
      end

      def dependencies
        if has_kernel_devel_info?
          # keep the original redhat dependencies
          super
        else
          # we should have installed kernel-devel-`uname -r` via install_kernel_devel
          ['gcc', 'binutils', 'make', 'perl', 'bzip2'].join(' ')
        end
      end
    end
  end
end
# Load this before the RedHat one, as we want it to be picked up first. (The higher the sooner its checked).
VagrantVbguest::Installer.register(VagrantVbguest::Installers::CentOS, 6)
