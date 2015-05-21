module VagrantVbguest
  module Installers
    class RedHat < Linux
      include VagrantVbguest::Helpers::Rebootable

      # Scientific Linux (and probably CentOS) both show up as :redhat
      # fortunately they're probably both similar enough to RHEL
      # (RedHat Enterprise Linux) not to matter.
      def self.match?(vm)
        :redhat == self.distro(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        check_kernel(opts, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      # on outdated CentOS Boxes, the kernel needs to be updated to install kernel-devel
      def check_kernel(opts=nil, &block)
        opts = {:error_check => false}.merge(opts || {})
        exit_status = communicate.sudo("yum check-update kernel", opts, &block)
        update_kernel(opts, &block) unless exit_status == 0
      end

      # update the kernel, then reboot and rerun VBGuest plugin
      def update_kernel(opts=nil, &block)
        communicate.sudo("yum install -y kernel", opts, &block)
        opts = {:auto_reboot => true}.merge(opts || {})
        #reboot(vm, opts)
      end

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
