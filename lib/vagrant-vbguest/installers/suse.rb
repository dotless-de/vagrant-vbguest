module VagrantVbguest
  module Installers
    class Suse < Linux
      # To distingish between OpenSuse and SLEs (both shows up as "suse"),
      # check for presence of the zypper and entry on os-release
      def self.match?(vm)
        :suse == self.distro(vm) && has_zypper?(vm) && sles?(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      def self.sles?(vm)
        communicate_to(vm).test "grep -q ID=\\\"sles\\\" /etc/os-release"
      end

      def self.has_zypper?(vm)
        communicate_to(vm).test "which zypper"
      end

      def install_dependencies_cmd
        "zypper --non-interactive install #{dependencies}"
      end

      def dependencies
        packages =  ['kernel-devel', 'gcc', 'make', 'tar']
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Suse, 6)
