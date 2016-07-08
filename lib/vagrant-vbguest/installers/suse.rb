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
        case sles_version
        when 10..11.4
              communicate.sudo(install_dependencies_cmd(pre_12=true), opts, &block)
        when 12.0..13.0
              communicate.sudo(install_dependencies_cmd, opts, &block)
        end
        super
      end

    protected
      def self.sles?(vm)
        communicate_to(vm).test "grep -q ID\"sles\" /etc/os-release"
      end

      def self.sles_version(vm)
        communicate_to(vm).sudo("cat /etc/os-release | grep VERSION_ID | cut -f2 -d'='", :error_check => false) do |t,d|
          return d.to_f
        end
      end

      def self.has_zypper?(vm)
        communicate_to(vm).test "which zypper"
      end

      def install_dependencies_cmd(pre_12=false)
        "zypper --non-interactive install #{dependencies(pre_12)}"
      end


      def dependencies(pre_12=false)
        packages = if pre_12
          ['kernel-default-devel', 'gcc', 'make', 'tar']
        else
          ['kernel-devel', 'gcc', 'make', 'tar']
        end
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Suse, 6)
