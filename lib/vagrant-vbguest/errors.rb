module VagrantVbguest

  class VbguestError < Vagrant::Errors::VagrantError
    def error_namespace; "vagrant_vbguest.errors"; end
  end

  class IsoPathAutodetectionError < VagrantVbguest::VbguestError
    error_key :autodetect_iso_path
  end

  class DownloadingDisabledError < VagrantVbguest::VbguestError
    error_key :downloading_disabled
  end

  class NoVirtualBoxMachineError < VagrantVbguest::VbguestError
    error_key :no_virtualbox_machine
  end
end
