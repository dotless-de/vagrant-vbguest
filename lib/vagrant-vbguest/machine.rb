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

      @installer = Installer.new(vm, options)
    end

    def run
      current_state = state
      runlist = steps(current_state)
      @logger.debug("Runlist for state #{current_state} is: #{runlist}")
      while (command = runlist.shift)
        @logger.debug("Running command #{command} from runlist")
        case self.send(command)
        when nil # skipped
          return false
        when false # machine state change error
          env.ui.error(I18n.t('vagrant_vbguest.machine_loop_guard', :command => command, :state => guest_additions_state.state))
          return false
        end
        return run if current_state != state
      end
      true
    end

    def install
      return env.ui.warn(I18n.t("vagrant_vbguest.skipped_installation")) if options[:no_install] && !options[:force]
      guest_additions_state.trigger :install
    end

    def rebuild
      return env.ui.warn(I18n.t("vagrant_vbguest.skipped_rebuild")) if options[:no_install] && !options[:force]
      guest_additions_state.trigger :rebuild
    end

    def start
      guest_additions_state.trigger :start
    end

    def installation_ran?; guest_additions_state.state == :installed end
    def started?; guest_additions_state.state == :started end
    def rebuilt?; guest_additions_state.state == :rebuilt end

    def reboot;  box_state.trigger :reboot end
    def reboot?; box_state.state == :rebooted end

    def steps(state)
      case state
      when :clean, :dirty, :unmatched
        [:install].tap { |l| l << :reboot if installer.reboot_after_install? }
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

      return :clean if !guest_version

      # some sort of distro installation bot no `vboxadd` tools to trigger rebuilds or manual starts
      return :dirty if installer.provides_vboxadd_tools? && !installer.vboxadd_tools_available?

      if host_version != guest_version
        return :unmatched if host_version > guest_version || options[:allow_downgrade] || options[:force]
        return :not_running if !running # still need to check this here, so we don't miss it before running into "skipped_downgrade"
        return :skipped_downgrade if host_version < guest_version
      end

      return :not_running if !running
      return :ok
    end

    def info
      {
        :vm_name => vm.name,
        :host_version => installer.host_version,
        :guest_version => installer.guest_version
      }
    end

    protected

      def guest_additions_state
        @guest_additions_state ||= MicroMachine.new(:pending).tap { |m|
          m.when :install, :pending => :installed
          m.when :start,   :pending => :started
          m.when :rebuild, :pending => :rebuilt, :started => :rebuilt

          m.on(:installed) { installer.install }
          m.on(:started)   { installer.start }
          m.on(:rebuilt)   { installer.rebuild }
        }
      end

      def box_state
        @box_state ||= MicroMachine.new(:first_boot).tap { |m|
          m.when :reboot, :first_boot => :rebooted
        }
      end
  end
end
