module VagrantVbguest
  
  class Config < Vagrant::Config::Base
    configures :vbguest
    attr_accessor :iso_path
    
  end
  
end