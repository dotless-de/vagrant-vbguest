require 'virtualbox'

module VagrantVbguest
  
  class Config < Vagrant::Config::Base
    attr_accessor :iso_path
    attr_accessor :auto_update
    
    def initialize
      super
      @auto_update = true
      autodetect_iso!
    end
    
    def validate(env, errors)
      errors.add(I18n.t("vagrant.plugins.vbguest.missing_iso_path")) unless iso_path && iso_path.is_a?(String) && File.exists?(iso_path)
    end

    # explicit hash, to get symbols in hash keys
    def to_hash
      {
        :iso_path => iso_path,
        :auto_update => auto_update
      }
    end
    
    protected
    
    def autodetect_iso!
      dvd = VirtualBox::DVD.all.find do |d|
        !!(d.location =~ /VBoxGuestAdditions.iso$/)
      end
      @iso_path = dvd.location if dvd
    end
  end
end
