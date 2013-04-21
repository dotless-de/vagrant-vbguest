module VagrantVbguest

  class DownloadBase
    attr_reader :source, :destination, :downloader

    def initialize(source, destination, options=nil)
      @downloader = nil
      @source = source
      @destination = destination
      if File.directory?(destination)
        @destination = File.join(destination, "vbguest_download_#{Time.now.to_i.to_s}")
      end
      @ui = options[:ui]
    end

    def download!
      raise NotImplementedError
    end

    def cleanup
      if destination && File.exist?(destination)
        @ui.info I18n.t("vagrant_vbguest.download.cleaning")
        File.unlink(destination)
      end
    end
  end

end
