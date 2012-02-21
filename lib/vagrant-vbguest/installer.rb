module VagrantVbguest

  # Handles the guest addins installation process

  class Installer

    def initialize(vm, options = {})
      @vm = vm
      @options = options
    end
    
    def run!
      @options[:auto_update] = true
      run
    end

    def run
      raise Vagrant::Errors::VMNotCreatedError if !@vm.created?
      raise Vagrant::Errors::VMInaccessible if !@vm.state == :inaccessible
      raise Vagrant::Errors::VMNotRunningError if @vm.state != :running

      if @options[:auto_update]
        @vm.ui.success(I18n.t("vagrant.plugins.vbguest.guest_ok", :version => guest_version)) unless needs_update?
        
        if @options[:force] || needs_update?
          @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.installing#{@options[:force] ? '_forced' : ''}", :host => vb_version, :guest => guest_version))
          
          # :TODO: 
          # the whole installation process should be put into own classes
          # like the vagrant system loading
          if (i_script = installer_script)
            @vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => iso_path, :to => iso_destination))
            @vm.channel.upload(iso_path, iso_destination)
            
            @vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_script", :from => File.basename(i_script), :to => installer_destination))
            @vm.channel.upload(i_script, installer_destination)
            
            @vm.channel.sudo("sh #{installer_destination}") do |type, data|
              # Print the data directly to STDOUT, not doing any newlines
              # or any extra formatting of our own
              $stdout.print(data) if type != :exit_status
            end

            @vm.channel.execute("rm /tmp/install_vbguest.sh /tmp/VBoxGuestAdditions.iso") do |type, data|
              # Print the data directly to STDOUT, not doing any newlines
              # or any extra formatting of our own
              $stdout.print(data) if type != :exit_status
            end

            # Puts out an ending newline just to make sure we end on a new
            # line.
            $stdout.puts
          end
        end
        
      end
    end
    
    def needs_update?
      !(guest_version && vb_version == guest_version)
    end
    
    def guest_version
      guest_version = @vm.driver.read_guest_additions_version
      !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')
    end

    def vb_version
      @vm.driver.version
    end

    def installer_script
      plattform = @vm.guest.distro_dispatch
      case plattform
      when :debian, :ubuntu
        File.expand_path("../../../files/setup_debian.sh", __FILE__)
      when :gentoo, :redhat, :suse, :arch, :linux
        @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.generic_install_script_for_plattform", :plattform => plattform.to_s))
        File.expand_path("../../../files/setup_linux.sh", __FILE__)
      else
        @vm.ui.error(I18n.t("vagrant.plugins.vbguest.no_install_script_for_plattform", :plattform => plattform.to_s))  
        nil
      end
    end
    
    def installer_destination
      '/tmp/install_vbguest.sh'
    end

    def iso_destination
      '/tmp/VBoxGuestAdditions.iso'
    end

    def iso_path
      @options[:iso_path]
    end
  end

end