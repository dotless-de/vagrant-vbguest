module VagrantVbguest
  class Download
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
      downloader_options = {}
      downloader_options[:ui] = @ui
      @ui.info(I18n.t("vagrant_vbguest.download.started", :source => @source))
      @downloader = Vagrant::Util::Downloader.new(@source, @destination, downloader_options)
      @downloader.download!
    end

    def cleanup
      if destination && File.exist?(destination)
        @ui.info I18n.t("vagrant_vbguest.download.cleaning")
        # Unlinking the downloaded file might crash on Windows
        # see: https://github.com/dotless-de/vagrant-vbguest/issues/189
        begin
          # Even if delete failed on Windows, we still can clean this file to save disk space
          File.open(destination,'wb') do |f|
            f.write('')
            f.close()
          end
          File.unlink(destination)
        rescue Errno::EACCES => e
          @ui.warn I18n.t("vagrant_vbguest.download.cleaning_failed", message: e.message, destination: destination)
        end
      end
    end
  end
end
