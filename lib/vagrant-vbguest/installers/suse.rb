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
        osr = self.os_release(vm)
        osr && osr["ID"] == "sles"
      end

      def self.has_zypper?(vm)
        communicate_to(vm).test "which zypper"
      end

      def install_dependencies_cmd
        "zypper --non-interactive install #{dependencies}"
      end


      def dependencies
        packages = case os_release["VERSION_ID"].to_f
                   when 10..11.4
                     ['kernel-default-devel', 'gcc', 'make', 'tar']
                   when 12.0..13.0
                     ['kernel-devel', 'gcc', 'make', 'tar']
                   end

        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Suse, 6)
