module VagrantVbguest
  
  class Config < Vagrant::Config::Base
    attr_accessor :iso_path
    attr_accessor :auto_update
    
    def initialize
      super
      @auto_update = true
      autodetect_iso!
    end
    
    def validate(errors)
      errors.add(I18n.t("vagrant.plugins.vbguest.missing_iso_path")) unless iso_path && iso_path.is_a?(String) && File.exists?(iso_path)
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