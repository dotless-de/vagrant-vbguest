require 'vagrant-vbguest/download'
module VagrantVbguest
  # This implementation is based on Action::Box::Download by vagrant
  #
  # This adoption does not run as a action/middleware, but is called manually
  #
  # MIT License - Mitchell Hashimoto and John Bender - https://github.com/mitchellh/vagrant
  #
  #
  #
  class Download < DownloadBase

    include Vagrant::Util

    def download!
      if instantiate_downloader
        File.open(@destination, Platform.tar_file_options) do |destination_file|
          @downloader.download!(@source, destination_file)
        end
      end
      @destination
    end

    def instantiate_downloader
      # Assign to a temporary variable since this is easier to type out,
      # since it is used so many times.
      classes = [Vagrant::Downloaders::HTTP, Vagrant::Downloaders::File]

      # Find the class to use.
      classes.each_index do |i|
        klass = classes[i]

        # Use the class if it matches the given URI or if this
        # is the last class...
        if classes.length == (i + 1) || klass.match?(@source)
          @ui.info I18n.t("vagrant_vbguest.download.with", :class => klass.to_s)
          @downloader = klass.new(@ui)
          break
        end
      end

      # This line should never be reached, but we'll keep this here
      # just in case for now.
      raise Errors::BoxDownloadUnknownType if !@downloader

      @downloader.prepare(@source) if @downloader.respond_to?(:prepare)
      true
    end

  end
end
