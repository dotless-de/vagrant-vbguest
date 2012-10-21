module VagrantVbguest

  class Config < Vagrant::Config::Base
    attr_accessor :iso_path
    attr_accessor :auto_update
    attr_accessor :no_install
    attr_accessor :no_remote
    
    def auto_update; @auto_update.nil? ? (@auto_update = true) : @auto_update; end
    def no_remote; @no_remote.nil? ? (@no_remote = false) : @no_remote; end
    def no_install; @no_install.nil? ? (@no_install = false): @no_install; end
    
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
