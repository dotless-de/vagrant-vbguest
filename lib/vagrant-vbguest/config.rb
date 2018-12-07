module VagrantVbguest

  class Config < Vagrant.plugin("2", :config)

    module Attributes
      attr_accessor :auto_update, :auto_reboot, :no_install, :no_remote,
                    :installer, :installer_arguments,
                    :iso_path, :iso_upload_path, :iso_mount_point, :yes
    end

    class << self
      include Attributes

      def auto_update; @auto_update.nil? ? true  : @auto_update end
      def auto_reboot; @auto_reboot.nil? ? true  : @auto_reboot end
      def no_install;  @no_install.nil?  ? false : @no_install  end
      def no_remote;   @no_remote.nil?   ? false : @no_remote   end
      def installer_arguments; @installer_arguments.nil? ? '--nox11' : @installer_arguments end
      def yes; @yes.nil? ? true : @yes end

      def iso_path
        return nil if !@iso_path || @iso_path == :auto
        @iso_path
      end
    end

    include Attributes

    def auto_update; @auto_update.nil? ? self.class.auto_update : @auto_update end
    def auto_reboot; @auto_reboot.nil? ? self.class.auto_reboot : @auto_reboot end
    def no_install;  @no_install.nil?  ? self.class.no_install  : @no_install  end
    def no_remote;   @no_remote.nil?   ? self.class.no_remote   : @no_remote   end
    def installer_arguments; @installer_arguments.nil? ? self.class.installer_arguments : @installer_arguments end
    def yes; @yes.nil? ? self.class.yes : @yes end

    def iso_path
      return self.class.iso_path if !@iso_path || @iso_path == :auto
      @iso_path
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :installer => installer,
        :installer_arguments => installer_arguments,
        :iso_path => iso_path,
        :iso_upload_path => iso_upload_path,
        :iso_mount_point => iso_mount_point,
        :auto_update => auto_update,
        :auto_reboot => auto_reboot,
        :no_install => no_install,
        :no_remote => no_remote,
        :yes => yes
      }
    end

  end
end
