module VagrantVbguest
  
  class Config < Vagrant::Config::Base
    configures :vbguest
    attr_accessor :iso_path
    
     def validate(errors)
       errors.add(I18n.t("vagrant.plugins.vbguest.missing_iso_path")) unless iso_path && iso_path.is_a?(String) && File.exists?(iso_path)
     end
  end
  
end