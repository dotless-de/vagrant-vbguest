module VagrantVbguest

  class VbguestError < Vagrant::Errors::VagrantError
    def error_namespace; "vagrant.plugins.vbguest.errors"; end
  end
  
  class IsoPathAutodetectionError < VagrantVbguest::VbguestError
    error_key :autodetect_iso_path
  end

  class DownloadingDisabledError < VagrantVbguest::VbguestError
    error_key :downloading_disabled
  end
end