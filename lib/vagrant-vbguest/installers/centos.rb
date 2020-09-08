module VagrantVbguest
  module Installers
    class CentOS < RedHat

      def self.match?(vm)
        super && communicate_to(vm).test('test -f /etc/centos-release')
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        if upgrade_kernel?
          upgrade_kernel(opts, &block)
        else
          install_kernel_deps(opts, &block)
        end
        super
      end

      def installer_options
        @installer_options ||= {
          allow_kernel_upgrade: false,
          reboot_timeout: 300
        }.merge!(super)
      end

      protected

      def upgrade_kernel?
        installer_options[:allow_kernel_upgrade]
      end

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
          @has_rel_repo = communicate.test('yum repolist')
        end
        @has_rel_repo
      end

      def release_version
        unless instance_variable_defined?(:@release_version)
          @release_version = nil
          version_pattern = /(\d+\.\d+(\.\d+)?)/
          communicate.sudo('cat /etc/centos-release') do |type, data|
            v = VagrantVbguest::Version(data, version_pattern)
            @release_version = v if v
          end
        end
        @release_version
      end

      def update_release_repos(opts=nil, &block)
        communicate.sudo('yum install -y centos-release', opts, &block)
      end

      def install_kernel_devel(opts=nil, &block)
        rel = has_rel_repo? ? release_version : '*'
        cmd = 'yum install -y kernel-devel-`uname -r`'
        communicate.sudo(cmd, opts, &block)
      end

      def upgrade_kernel(opts=nil, &block)
        communicate.sudo('yum update -y kernel', opts, &block)
        communicate.sudo('yum install -y kernel-devel', opts, &block)

        env.ui.info(I18n.t("vagrant_vbguest.centos.rebooting", vm_name: vm.name))
        communicate.sudo('shutdown -r now', opts, &block)

        sleep_guard = installer_options[:reboot_timeout]
        begin
          sleep 10
          sleep_guard -= 10
        end while sleep_guard >= 0 && !@vm.communicate.ready?
      end

      def dependencies
        if !upgrade_kernel? && has_kernel_devel_info?
          # keep the original redhat dependencies
          super
        else
          # we should have installed kernel-devel(-`uname -r`) via install_kernel_devel or upgrade_kernel
          ['gcc', 'binutils', 'make', 'perl', 'bzip2', 'elfutils-libelf-devel'].join(' ')
        end
      end
    end
  end
end
# Load this before the RedHat one, as we want it to be picked up first. (The higher the sooner its checked).
VagrantVbguest::Installer.register(VagrantVbguest::Installers::CentOS, 6)
