module VagrantVbguest
  
  # A Vagrant middleware which checks the installed VirtualBox Guest
  # Additions to match the installed VirtualBox installation on the 
  # host system.
  
  class Middleware
    def initialize(app, env)
      @app = app
      @env = env
    end

    def call(env)
      
      version = env["vm"].vm.interface.get_guest_property_value("/VirtualBox/GuestAdd/Version")
      needs_update = version.empty? || (VirtualBox.version != version.gsub(/[-_]ose/i, ''))

      env.ui.warn(I18n.t("vagrant.plugins.vbguest.installing", :version => VirtualBox.version))
      
      if env["vm"].created? && env["vm"].vm.running?
        
        env["vm"].ssh.upload!(iso_path, '/tmp/VBoxGuestAdditions.iso')
        env["vm"].ssh.upload!(File.expand_path("../../files/setup_debian.sh", __FILE__), '/tmp/install_vbguest.sh')
        
        env["vm"].ssh.execute do |ssh|
          ssh.sudo!("sh /tmp/install_vbguest.sh") do |channel, type, data|
            # Print the data directly to STDOUT, not doing any newlines
            # or any extra formatting of our own
            $stdout.print(data) if type != :exit_status
          end
          
          # Puts out an ending newline just to make sure we end on a new
          # line.
          $stdout.puts
        end
        
      end

      @app.call(env)
    end
  end
  
  protected
  
  def iso_path
    @env["config"].vbguest.iso_path
  end
  
end

