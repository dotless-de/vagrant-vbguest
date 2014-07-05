module VagrantVbguest
  module Installers
    class Windows < Base
      include VagrantVbguest::Helpers::VmCompatible
      
      def self.match?(vm)
        :windows == self.distro(vm)
      end

      def install(opts=nil, &block)
        file = additions_file
        uuid = @vm.id
        cmd = "\"#{vboxmanage_path}\" guestcontrol \"#{uuid}\" updateadditions --source \"#{file}\" --verbose"
        @vm.env.ui.info "cmd: #{cmd}"
        result = Vagrant::Util::Subprocess.execute(
          'bash',
          '-c',
          cmd,
          :notify => [:stdout, :stderr]
        #  :workdir => config.cwd
        ) do |io_name, data|
          @vm.env.ui.info "#{data}"
        end
      end
      
      def vboxmanage_path
        if (p = ENV["VBOX_INSTALL_PATH"]) && !p.empty?
          File.join(p, "VBoxManage.exe")
        elsif (p = ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]) && !p.empty?
          File.join(p, "\\Oracle\\VirtualBox\\VBoxManage.exe")
        end
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Windows, 6)
