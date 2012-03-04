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
      @iso_path ||= (media_magager_iso || guess_iso || web_iso)
    end

    def media_magager_iso
      dvd = VirtualBox::DVD.all.find do |d|
        !!(d.location =~ /VBoxGuestAdditions.iso$/)
      end
      dvd ? dvd.location : nil
    end

    def guess_iso
      guess_path = if Vagrant::Util::Platform.linux?
        "/usr/share/virtualbox/VBoxGuestAdditions.iso"
      elsif Vagrant::Util::Platform.darwin?
        "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
      elsif Vagrant::Util::Platform.windows?
        File.join((ENV["PROGRAM_FILES"] || ENV["PROGRAMFILES"]), "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
      end
      File.exists?(guess_path) ? guess_path : nil
    end

    def web_iso
      "http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso"
    end

  end
end
