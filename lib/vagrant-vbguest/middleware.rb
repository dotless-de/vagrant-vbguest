module VagrantVbguest
  
  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the 
  # host system.
  
  class Middleware
    def initialize(app, env, options = {})
      @app = app
      @env = env
      @run_level = options.delete(:run_level)
      @force = options.delete(:force) || env["vbguest.force.install"]
    end

    def call(env)

      if shall_run?
        version = env["vm"].vm.interface.get_guest_property_value("/VirtualBox/GuestAdd/Version")
        guest_version = version.empty?() ? I18n.t("vagrant.plugins.vbguest.additions_missing_on_guest") : version.gsub(/[-_]ose/i, '');
        needs_update = version.empty? || (VirtualBox.version != guest_version)

        if forced_run? || needs_update
          env.ui.warn(I18n.t("vagrant.plugins.vbguest.installing", :host => VirtualBox.version, :guest => guest_version))
      
          env.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => iso_path, :to => iso_destination))
          env["vm"].ssh.upload!(iso_path, iso_destination)
      
          env.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_script", :from => File.basename(installer_script), :to => installer_destination))
          env["vm"].ssh.upload!(installer_script, installer_destination)
        
          env["vm"].ssh.execute do |ssh|
            ssh.sudo!("sh /tmp/install_vbguest.sh") do |channel, type, data|
              # Print the data directly to STDOUT, not doing any newlines
              # or any extra formatting of our own
              $stdout.print(data) if type != :exit_status
            end
          
            ssh.exec!("rm /tmp/install_vbguest.sh /tmp/VBoxGuestAdditions.iso") do |channel, type, data|
              # Print the data directly to STDOUT, not doing any newlines
              # or any extra formatting of our own
              $stdout.print(data) if type != :exit_status
            end
          
            # Puts out an ending newline just to make sure we end on a new
            # line.
            $stdout.puts
          end
        else
          env.ui.info(I18n.t("vagrant.plugins.vbguest.guest_ok", :version => guest_version))
        end
      end

      @app.call(env)
    end
    
    protected

    def forced_run?
      @force
    end

    def vm_up?
      @env["vm"].created? && @env["vm"].vm.running?
    end
    
    def shall_run?
      vm_up? && (forced_run? || !@run_level || @env["config"].vbguest.auto_update)
    end

    def iso_path
      @env["config"].vbguest.iso_path
    end
    
    def iso_destination
      '/tmp/VBoxGuestAdditions.iso'
    end
    
    def installer_script
      File.expand_path("../../../files/setup_debian.sh", __FILE__)
    end
    
    def installer_destination
      '/tmp/install_vbguest.sh'
    end
  end
  
end
