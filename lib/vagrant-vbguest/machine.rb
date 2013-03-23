module VagrantVbguest
  class Machine

    require 'micromachine'

    attr_reader :installer, :env, :vm, :options

    def initialize vm, options
      @vm       = vm
      @env      = vm.env
      @options  = options

      @logger = Log4r::Logger.new("vagrant::plugins::vbguest-machine")
      @logger.debug("initialize vbguest machine for VM '#{vm.name}' (#{vm.to_s})")

      @installer = Installer.new vm, options

      @ga_machine = MicroMachine.new(:pending).tap { |m|
        m.when :install, :pending => :installed
        m.when :start,   :pending => :started
        m.when :rebuild, :pending => :rebuilt, :started => :rebuilt

        m.on(:installed) { installer.install }
        m.on(:started)   { installer.start }
        m.on(:rebuilt)   { installer.rebuild }
      }

      @box_machine = MicroMachine.new(:first_boot).tap { |m|
        m.when :reboot, :first_boot => :rebooted
      }
    end

    def run
      current_state = state
      runlist = steps(current_state)
      @logger.debug("Runlist for state #{current_state} is: #{runlist}")
      while (command = runlist.shift)
        @logger.debug("Running command #{command} from runlist")
        if !self.send(command)
          env.ui.error('vagrant.plugins.vbguest.machine_loop_guard', :command => command, :state => current_state)
          return false
        end
        return run if current_state != state
      end
      true
    end

    def install
      return env.ui.warn(I18n.t("vagrant.plugins.vbguest.skipped_installation")) if options[:no_install] && !options[:force]
      @ga_machine.trigger :install
    end

    def rebuild
      return env.ui.warn(I18n.t("vagrant.plugins.vbguest.skipped_rebuild")) if options[:no_install] && !options[:force]
      @ga_machine.trigger :rebuild
    end

    def start
      @ga_machine.trigger :start
    end

    def installation_ran?; @ga_machine == :installed end
    def started?; @ga_machine == :started end
    def rebuilt?; @ga_machine == :rebuilt end

    def reboot;  @box_machine.trigger :reboot end
    def reboot?; @box_machine.state == :rebooted end

    def steps(state)
      case state
      when :clean, :unmatched
        [:install]
      when :not_running
        installation_ran? ? [:reboot] : [:start, :rebuild, :reboot]
      else
        []
      end
    end

    def state
      guest_version = installer.guest_version(true)
      host_version  = installer.host_version
      running = installer.running?
      @logger.debug("Current states for VM '#{vm.name}' are : guest_version=#{guest_version} : host_version=#{host_version} : running=#{running}")

      return :clean       if !guest_version
      return :unmatched   if host_version != guest_version
      return :not_running if !running
      return :ok
    end

    def info
      {
        :host_version => installer.host_version,
        :guest_version => installer.guest_version
      }
    end
  end
end
