module VagrantVbguest
  module Helpers
    class << self

      def local_iso_path_for(vm, options = nil)
        options ||= {}
        @local_iso_paths ||= Hash.new
        @local_iso_paths[vm.uuid] ||= media_manager_iso(vm) || guess_iso(vm)
      end

      def web_iso_path_for(vm, options = nil)
        options ||= {}
        "http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso"
      end

      def media_manager_iso(vm)
        (m = vm.driver.execute('list', 'dvds').match(/^.+:\s+(.*VBoxGuestAdditions.iso)$/i)) && m[1]
      end

      def guess_iso(vm)
        path_platform = if Vagrant::Util::Platform.linux?
          "/usr/share/virtualbox/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.darwin?
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.windows?
          if (p = ENV["VBOX_INSTALL_PATH"]) && !p.empty?
            File.join(p, "VBoxGuestAdditions.iso")
          else
            File.join((ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]), "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
          end
        end
        File.exists?(path_platform) ? path_platform : nil
      end

      def kernel_module_running?(vm, &block)
        vm.channel.test('lsmod | grep vboxsf', :sudo => true, &block)
      end

    end
  end
end