module VagrantVbguest
  module Installers
    class RedHat < Linux
      # Scientific Linux and CentOS show up as :redhat (or "centos7")
      # fortunately they're probably both similar enough to RHEL
      # (RedHat Enterprise Linux) not to matter.
      def self.match?(vm)
        /\A(redhat|centos|amazon|rocky|alma)\d*\Z/ =~ self.distro(vm)
      end

      # Install missing deps and yield up to regular linux installation
      def install(opts=nil, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      def install_dependencies_cmd
        "#{package_manager_cmd} install -y #{dependencies}"
      end

      def package_manager_cmd
        "`bash -c 'type -p dnf || type -p yum'`"
      end

      def dependencies
        [
          'kernel-devel',
          'kernel-devel-`uname -r`',
          'gcc',
          'binutils',
          'make',
          perl_dependency,
          'bzip2',
          'elfutils-libelf-devel'
        ].join(' ')
      end

      def perl_dependency
        unless instance_variable_defined?(:@perl_dependency)
          @perl_dependency = if communicate.test("#{package_manager_cmd} list perl-interpreter")
            "perl-interpreter"
          else
            "perl"
          end
        end
        @perl_dependency
      end
    end
  end
end
VagrantVbguest::Installer.register(:redhat, VagrantVbguest::Installers::RedHat, 5)
VagrantVbguest::Installer.register(:red_hat, VagrantVbguest::Installers::RedHat, 5)
