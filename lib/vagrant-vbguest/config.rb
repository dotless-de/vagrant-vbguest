module VagrantVbguest

  class Config < Vagrant::Config::Base

    module Attributes
      attr_accessor :iso_path, :auto_update, :no_install, :no_remote
    end

    class << self
      include Attributes

      def auto_update; @auto_update.nil? ? true  : @auto_update end
      def no_install;  @no_install.nil?  ? false : @no_install  end
      def no_remote;   @no_remote.nil?   ? false : @no_remote   end

      def iso_path
        return nil if !@iso_path || @iso_path == :auto
        @iso_path
      end
    end

    include Attributes

    def auto_update; @auto_update.nil? ? self.class.auto_update : @auto_update end
    def no_install;  @no_install.nil?  ? self.class.no_install  : @no_install  end
    def no_remote;   @no_remote.nil?   ? self.class.no_remote   : @no_remote   end

    def iso_path
      return self.class.iso_path if !@iso_path || @iso_path == :auto
      @iso_path
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :iso_path => iso_path,
        :auto_update => auto_update,
        :no_install => no_install,
        :no_remote => no_remote
      }
    end

  end
end
