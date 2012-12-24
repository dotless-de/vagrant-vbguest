module VagrantVbguest
  class Machine

    require 'micromachine'

    attr_reader :installer, :vm, :options

    def initialize vm, options
      @vm = vm
      @options = options
      @installer = Installer.new @vm, @options

      @ga_machine = MicroMachine.new :pending
      @ga_machine.when :install, :pending => :installed
      @ga_machine.when :start, :pending => :started
      @ga_machine.when :rebuild, :pending => :rebuilt, :started => :rebuilt

      @ga_machine.on(:installed) { installer.install }
      @ga_machine.on(:started)   { installer.start }
      @ga_machine.on(:rebuilt)   { installer.rebuild }

      @box_machine = MicroMachine.new :first_boot
      @box_machine.when :reboot, :first_boot => :rebooted
    end

    def run
      current_state = state
      runlist = steps(current_state)
      while (command = runlist.shift)
        self.send(command)
        return run if current_state != state
      end
    end

    def install
      return @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.skiped_installation")) if options[:no_install] && !options[:force]
      @ga_machine.trigger :install
    end

    def rebuild
      return @vm.ui.warn(I18n.t("vagrant.plugins.vbguest.skiped_rebuild")) if options[:no_install] && !options[:force]
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