module VagrantVbguest
  
  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the 
  # host system.
  
  class Middleware
    def initialize(app, env, options = {})
      @app = app
      @env = env
      @vm = version = env[:vm]
      @run_level = options.delete(:run_level)
      @force = options.delete(:force) || env["vbguest.force.install"]
    end

    def call(env)
      
      if shall_run? 
        
        @env[:ui].success(I18n.t("vagrant.plugins.vbguest.guest_ok", :version => guest_version)) unless needs_update?
        
        if forced_run? || needs_update?
          @env[:ui].warn(I18n.t("vagrant.plugins.vbguest.installing#{forced_run? ? '_forced' : ''}", :host => vb_version, :guest => guest_version))
          
          # :TODO: 
          # the whole installation process should be put into own classes
          # like the vagrant system loading
          if i_script = installer_script
            @env[:ui].info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => iso_path, :to => iso_destination))
            @vm.channel.upload(iso_path, iso_destination)
            
            @env[:ui].info(I18n.t("vagrant.plugins.vbguest.start_copy_script", :from => File.basename(i_script), :to => installer_destination))
            @vm.channel.upload(i_script, installer_destination)
            
            @vm.channel.sudo("sh /tmp/install_vbguest.sh") do |type, data|
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
      
      @app.call(env)
    end
    
    protected

    def forced_run?
      @force
    end
    
    def needs_update?
      !(guest_version && vb_version == guest_version)
    end

    def vm_up?
      @vm.created? && @env[:vm].state == :running
    end
    
    def shall_run?
      vm_up? && (forced_run? || !@run_level || @env[:vm].config.vbguest.auto_update)
    end
    
    def guest_version
      guest_version = @vm.driver.read_guest_additions_version
      !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')
    end

    def vb_version
      @env[:vm].driver.version
    end

    def iso_path
      @env[:vm].config.vbguest.iso_path
    end
    
    def iso_destination
      '/tmp/VBoxGuestAdditions.iso'
    end
    
    def installer_script
      plattform = @env[:vm].guest.distro_dispatch
      case plattform
      when :debian, :ubuntu
        return File.expand_path("../../../files/setup_debian.sh", __FILE__)
      when :gentoo, :redhat, :suse, :arch, :linux
        @env[:ui].error(I18n.t("vagrant.plugins.vbguest.generic_install_script_for_plattform", :plattform => plattform.to_s))
        return File.expand_path("../../../files/setup_linux.sh", __FILE__)
      end
      @env[:ui].error(I18n.t("vagrant.plugins.vbguest.no_install_script_for_plattform", :plattform => plattform.to_s))
      nil
    end
    
    def installer_destination
      '/tmp/install_vbguest.sh'
    end
  end
  
end
