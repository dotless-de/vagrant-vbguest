module VagrantVbguestUnikorn
  # This installer overwrites the matching and installing methods only.
  # Please have a look at the VagrantVbguest::Installers::Linux class
  # (https://github.com/dotless-de/vagrant-vbguest/blob/main/lib/vagrant-vbguest/installers/linux.rb)
  # for possibly other interesting methods worth customizing. For example:
  #    - running?
  #    - start
  #    - guest_version
  #    - rebuild
  class Installer < VagrantVbguest::Installers::Linux
    # Checks if this Installer should be used for the current vm (guest system)
    # Returns True or False
    def self.match?(vm)
      vm.env.ui.info "Checking Installer: #{self}"

      # check either on what vagrant identified as distribution:
      #   :unikorn == self.distro(vm)
      # or:
      #   /\Auni(c|k)orn\d*\Z/i =~ self.distro(vm)

      # Or run some script on the guest system:
      #   communicate_to(vm).test('test -f /etc/unikorn_version')

      # THIS SAMPLE JUST RETURNS TRUE FOR THE SAKE OF TESTING
      # YOU NEED TO IMPLEMENT THE MATCHING!
      1 == 1
    end

    def install(opts=nil, &block)
      env.ui.info "Using Installer: #{self.class.name}"

      # runs a command line which installs all necessary libraries/packages
      # for building the guest additions. Usually this includes kernel headers
      # matching the currently running kernel
      communicate.sudo("apt-get install linux-headers-`uname -r`", opts, &block)

      # we need to call `super` in order to proceed with vagrant-vbguest's
      # installation routine
      super
    end
  end
end

# This registers our new Installer class at VagrantVbguest
# Using a higher number as priority (second parameter) will let vagrant-vbguest
# prefer this installer over others (only if `match?` was successful).
VagrantVbguest::Installer.register(VagrantVbguestUnikorn::Installer, 10)
