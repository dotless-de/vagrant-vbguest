require 'vagrant-vbguest/download'
require "vagrant/util/downloader"

module VagrantVbguest

  class Download < DownloadBase

    def download!
      downloader_options = {}
      downloader_options[:ui] = @ui
      @ui.info(I18n.t("vagrant_vbguest.download.started", :source => @source))
      @downloader = Vagrant::Util::Downloader.new(@source, @destination, downloader_options)
      @downloader.download!
    end

  end

end
