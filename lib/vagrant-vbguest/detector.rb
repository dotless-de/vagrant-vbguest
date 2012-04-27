module VagrantVbguest

  class Detector

    def initialize(vm, options)
      @vm = vm
      @options = options
    end

    def iso_path
      @iso_path ||= autodetect_iso
    end

    private

      def autodetect_iso
        path = media_manager_iso || guess_iso || web_iso
        raise VagrantVbguest::IsoPathAutodetectionError if !path || path.empty?
        path
      end

      def media_manager_iso
        (m = @vm.driver.execute('list', 'dvds').match(/^.+:\s+(.*VBoxGuestAdditions.iso)$/i)) && m[1]
      end

      def guess_iso
        path_platform = if Vagrant::Util::Platform.linux?
          "/usr/share/virtualbox/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.darwin?
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        elsif Vagrant::Util::Platform.windows?
          File.join((ENV["PROGRAM_FILES"] || ENV["PROGRAMFILES"]), "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
        end
        File.exists?(path_platform) ? path_platform : nil
      end

      def web_iso
        "http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso" unless @options[:no_remote]
      end

  end
end